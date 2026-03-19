import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'features/sms/providers/sms_provider.dart';
import 'main.dart' show requestNotificationPermission;
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
      final isAuth = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState.status == AuthStatus.unknown) return null;

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/';

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
