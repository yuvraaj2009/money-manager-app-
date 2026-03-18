import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/models/transaction.dart';
import '../../../shared/providers/api_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

final pendingTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final api = ref.watch(smsApiProvider);
  return api.getPending();
});

class SmsPendingScreen extends ConsumerWidget {
  const SmsPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pending = ref.watch(pendingTransactionsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(pendingTransactionsProvider),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Row(
                  children: [
                    Text('Pending Transactions', style: theme.textTheme.headlineMedium),
                    const SizedBox(width: 8),
                    pending.when(
                      data: (txs) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${txs.length} pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Review auto-detected transactions from your bank SMS messages.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),

              pending.when(
                data: (txs) {
                  if (txs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(48),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.check_circle_outline, size: 64, color: theme.colorScheme.secondary),
                            const SizedBox(height: 16),
                            Text('All caught up!', style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                              'No pending transactions to review.',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      ...txs.map((tx) => _PendingCard(
                        transaction: tx,
                        theme: theme,
                        isDark: isDark,
                        onConfirm: () async {
                          await ref.read(smsApiProvider).confirm(tx.id);
                          ref.invalidate(pendingTransactionsProvider);
                          ref.invalidate(dashboardSummaryProvider);
                          ref.invalidate(recentTransactionsProvider);
                        },
                        onReject: () async {
                          await ref.read(smsApiProvider).reject(tx.id);
                          ref.invalidate(pendingTransactionsProvider);
                        },
                      )),
                      const SizedBox(height: 16),
                      if (txs.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.primaryContainer,
                                  ],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: () async {
                                  for (final tx in txs) {
                                    await ref.read(smsApiProvider).confirm(tx.id);
                                  }
                                  ref.invalidate(pendingTransactionsProvider);
                                  ref.invalidate(dashboardSummaryProvider);
                                  ref.invalidate(recentTransactionsProvider);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: const StadiumBorder(),
                                ),
                                child: Text(
                                  'Confirm All Transactions',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Error: $e'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final Transaction transaction;
  final ThemeData theme;
  final bool isDark;
  final VoidCallback onConfirm;
  final VoidCallback onReject;

  const _PendingCard({
    required this.transaction,
    required this.theme,
    required this.isDark,
    required this.onConfirm,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final amountColor = isExpense
        ? (isDark ? AppTheme.expenseRedDark : AppTheme.expenseRed)
        : (isDark ? AppTheme.incomeGreenDark : AppTheme.incomeGreen);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.receipt_long, color: theme.colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'Unknown Merchant',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        '${transaction.accountName ?? 'Bank'} \u2022 ${DateFormat('dd MMM, hh:mm a').format(transaction.date)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Amount row
            Row(
              children: [
                Text(
                  '${isExpense ? '-' : '+'}${CurrencyFormatter.format(transaction.amount)}',
                  style: GoogleFonts.manrope(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: amountColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isExpense ? 'Debit' : 'Credit',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: amountColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Confidence + Category
            Row(
              children: [
                Icon(Icons.verified, color: theme.colorScheme.secondary, size: 16),
                const SizedBox(width: 4),
                Text(
                  'High Confidence',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const Spacer(),
                Text(
                  transaction.categoryName ?? 'Uncategorized',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Confirm', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text('Reject', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
