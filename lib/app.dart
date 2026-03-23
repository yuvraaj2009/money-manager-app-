import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/sms/providers/sms_provider.dart';
import 'main.dart' show requestNotificationPermission, getPendingSmsFromNative, clearPendingSmsNative;
import 'shared/providers/api_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/theme_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/transactions/screens/add_transaction_screen.dart';
import 'features/transactions/screens/transaction_detail_screen.dart';
import 'features/reports/screens/analytics_screen.dart';
import 'features/reports/screens/budget_screen.dart';
import 'features/dashboard/screens/goals_screen.dart';
import 'features/sms/screens/sms_pending_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/categories/screens/category_manager_screen.dart';
import 'shared/widgets/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final status = authState.status;
      final isAuth = status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      debugPrint('ROUTER REDIRECT: status=$status, path=${state.matchedLocation}, isAuth=$isAuth, isAuthRoute=$isAuthRoute');

      if (status == AuthStatus.unknown) {
        debugPrint('ROUTER REDIRECT: status=unknown, showing splash (no redirect)');
        return null;
      }

      if (!isAuth && !isAuthRoute) {
        debugPrint('ROUTER REDIRECT: not auth + not auth route → /login');
        return '/login';
      }
      if (isAuth && isAuthRoute) {
        debugPrint('ROUTER REDIRECT: auth + on auth route → /');
        return '/';
      }

      debugPrint('ROUTER REDIRECT: no redirect needed');
      return null;
    },
    routes: [
      // Auth routes (no bottom nav)
      GoRoute(
        path: '/login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Main app shell with bottom nav
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/sms-pending',
            builder: (context, state) => const SmsPendingScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoryManagerScreen(),
          ),
          GoRoute(
            path: '/goals',
            builder: (context, state) => const GoalsScreen(),
          ),
        ],
      ),

      // Full-screen routes (no bottom nav)
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/transaction/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionDetailScreen(transactionId: id);
        },
      ),
    ],
  );
});

class MoneyManagerApp extends ConsumerStatefulWidget {
  const MoneyManagerApp({super.key});

  @override
  ConsumerState<MoneyManagerApp> createState() => _MoneyManagerAppState();
}

class _MoneyManagerAppState extends ConsumerState<MoneyManagerApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) => _initPermissions());
  }

  Future<void> _initPermissions() async {
    if (_initialized) return;
    _initialized = true;

    // Request notification permission (Android 13+)
    await requestNotificationPermission();

    // Auto-start SMS listener if previously enabled
    final smsService = ref.read(smsListenerProvider);
    final smsEnabled = await smsService.isEnabled();
    if (smsEnabled) {
      smsService.startListening();
    }

    // Process any SMS captured by BroadcastReceiver while app was closed
    _processPendingNativeSms();

    // Show battery optimization dialog once
    _showBatteryOptimizationTip();
  }

  Future<void> _showBatteryOptimizationTip() async {
    const storage = FlutterSecureStorage();
    const key = 'battery_tip_shown';
    final shown = await storage.read(key: key);
    if (shown == 'true') return;

    // Wait for auth to resolve — only show if user is logged in
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final authState = ref.read(authProvider);
    if (authState.status != AuthStatus.authenticated) return;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Improve SMS Tracking'),
        content: const Text(
          'For best SMS tracking, please disable battery optimization for Money Manager.\n\n'
          'Go to: Settings \u2192 Apps \u2192 Money Manager \u2192 Battery \u2192 Unrestricted',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
    await storage.write(key: key, value: 'true');
  }

  Future<void> _processPendingNativeSms() async {
    try {
      debugPrint('SMS_PENDING: checking SharedPreferences for stored SMS...');
      final pending = await getPendingSmsFromNative();
      debugPrint('SMS_PENDING: found ${pending.length} pending SMS');

      if (pending.isEmpty) return;

      // Wait for auth to be ready before calling API
      final authState = ref.read(authProvider);
      if (authState.status != AuthStatus.authenticated) {
        debugPrint('SMS_PENDING: not authenticated yet, deferring processing');
        return;
      }

      final smsApi = ref.read(smsApiProvider);
      for (final sms in pending) {
        final body = sms['body'] ?? '';
        final sender = sms['sender'] ?? '';
        final timestamp = sms['timestamp'] ?? '';
        debugPrint('SMS_PENDING: processing SMS from "$sender": "${body.length > 80 ? body.substring(0, 80) : body}..."');

        if (body.isNotEmpty) {
          try {
            final result = await smsApi.parseSms(
              body,
              sender: sender,
              timestamp: timestamp.isNotEmpty ? timestamp : null,
            );
            debugPrint('SMS_PENDING: API response = $result');
          } catch (e) {
            debugPrint('SMS_PENDING: API call FAILED for SMS: $e');
          }
        }
      }
      await clearPendingSmsNative();
      debugPrint('SMS_PENDING: cleared pending SMS from native storage');
    } catch (e) {
      debugPrint('SMS_PENDING: ERROR processing pending SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Money Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
