import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/transaction_list_item.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/allocations_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summary = ref.watch(dashboardSummaryProvider);
    final recentTx = ref.watch(recentTransactionsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardSummaryProvider);
            ref.invalidate(recentTransactionsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.secondary,
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Money Manager',
                      style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
                      icon: Icon(
                        Icons.light_mode_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Balance card
              summary.when(
                data: (s) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: BalanceCard(summary: s),
                ),
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _LoadingCard(height: 180),
                ),
                error: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: BalanceCard(summary: null),
                ),
              ),
              const SizedBox(height: 20),

              // Quick Insight card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'QUICK INSIGHT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurfaceVariant,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.auto_awesome, color: theme.colorScheme.primary, size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Smart Budget',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "You've spent 64% of your monthly dining budget. Consider cooking at home this weekend.",
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.64,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Goals Summary
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => context.go('/goals'),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Goals Summary', style: theme.textTheme.headlineSmall),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: 0.75,
                                    strokeWidth: 6,
                                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                                  ),
                                  Text(
                                    '75%',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total goals reached', style: theme.textTheme.titleSmall),
                                Text('Keep it up!', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Allocations
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text('Allocations', style: theme.textTheme.headlineSmall),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/analytics'),
                      child: Text('View Report'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              summary.when(
                data: (s) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AllocationsChart(breakdown: s.categoryBreakdown),
                ),
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _LoadingCard(height: 200),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Recent Ledger
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Recent Ledger', style: theme.textTheme.headlineSmall),
              ),
              const SizedBox(height: 12),
              recentTx.when(
                data: (txs) => txs.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              'No transactions yet.\nTap + to add your first one!',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: txs.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) => TransactionListItem(transaction: txs[i]),
                      ),
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _LoadingCard(height: 120),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Error loading transactions', style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({required this.height});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
