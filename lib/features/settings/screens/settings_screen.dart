import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../sms/providers/sms_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _smsAutoTracking = false;
  bool _loadingPref = true;

  @override
  void initState() {
    super.initState();
    _loadSmsPref();
  }

  Future<void> _loadSmsPref() async {
    final sms = ref.read(smsListenerProvider);
    final enabled = await sms.isEnabled();
    if (mounted) setState(() { _smsAutoTracking = enabled; _loadingPref = false; });
  }

  Future<void> _onSmsToggle(bool value) async {
    final sms = ref.read(smsListenerProvider);

    if (!value) {
      // Turning OFF
      sms.stopListening();
      await sms.setEnabled(false);
      setState(() => _smsAutoTracking = false);
      return;
    }

    // Turning ON — check permissions
    final smsStatus = await Permission.sms.status;
    if (smsStatus.isGranted) {
      await sms.setEnabled(true);
      sms.startListening();
      setState(() => _smsAutoTracking = true);
      return;
    }

    // Show explanation dialog
    if (!mounted) return;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('SMS Permission Required'),
        content: const Text(
          'Money Manager needs SMS access to automatically detect bank '
          'transactions. Your SMS data stays on this device — only parsed '
          'amounts and categories are sent to the server.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Allow'),
          ),
        ],
      ),
    );

    if (proceed != true) return;

    // Request permissions
    final results = await [
      Permission.sms,
    ].request();

    final granted = results[Permission.sms]?.isGranted ?? false;

    if (granted) {
      await sms.setEnabled(true);
      sms.startListening();
      setState(() => _smsAutoTracking = true);
    } else {
      setState(() => _smsAutoTracking = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('SMS permission required for auto-tracking')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const SizedBox(height: 16),

            // Profile header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : 'U',
                          style: GoogleFonts.manrope(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          child: Icon(Icons.edit, color: theme.colorScheme.onPrimary, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'User',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        user?.email ?? '',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ACCOUNT section
            _SectionLabel('ACCOUNT'),
            _SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'My Accounts',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.category_outlined,
              title: 'Categories',
              onTap: () => context.go('/categories'),
            ),

            const SizedBox(height: 24),

            // SMS section
            _SectionLabel('SMS'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sms_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('SMS Auto-Tracking', style: theme.textTheme.titleSmall),
                    ),
                    _loadingPref
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                        : Switch(
                            value: _smsAutoTracking,
                            onChanged: _onSmsToggle,
                            activeTrackColor: theme.colorScheme.primary,
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.phone_android,
              title: 'Supported Banks',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.pending_actions,
              title: 'Pending SMS Transactions',
              onTap: () => context.go('/sms-pending'),
            ),

            const SizedBox(height: 24),

            // DATA section
            _SectionLabel('DATA'),
            _SettingsTile(
              icon: Icons.file_download_outlined,
              title: 'Export Data',
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.assessment_outlined,
              title: 'Monthly Reports',
              onTap: () => context.go('/budget'),
            ),

            const SizedBox(height: 24),

            // APP section
            _SectionLabel('APP'),
            _SettingsTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {},
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.dark_mode_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Dark Mode', style: theme.textTheme.titleSmall)),
                    Switch(
                      value: theme.brightness == Brightness.dark,
                      onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
                      activeTrackColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.currency_rupee,
              title: 'Currency',
              trailing: Text('\u20B9 INR', style: theme.textTheme.bodyMedium),
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {},
            ),

            const SizedBox(height: 32),

            // Sign Out
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                child: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: theme.textTheme.titleSmall)),
              trailing ?? Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
