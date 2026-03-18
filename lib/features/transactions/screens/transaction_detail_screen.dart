import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/providers/api_provider.dart';
import '../providers/transaction_provider.dart';
import '../../dashboard/providers/dashboard_provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final txAsync = ref.watch(transactionDetailProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back),
        ),
        title: const Text('Transaction Detail'),
      ),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tx) {
          final isExpense = tx.type == 'expense';
          final amountColor = isExpense
              ? (isDark ? AppTheme.expenseRedDark : AppTheme.expenseRed)
              : (isDark ? AppTheme.incomeGreenDark : AppTheme.incomeGreen);

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // Status badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tx.isConfirmed ? 'Completed' : 'Pending',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Source: ${tx.source == 'sms' ? 'SMS Auto-Parsed' : 'Manual'}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Amount
                Text(
                  '${isExpense ? '-' : '+'}${CurrencyFormatter.format(tx.amount)}',
                  style: GoogleFonts.manrope(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(tx.date),
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.edit_outlined),
                        label: Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Transaction'),
                              content: const Text('Are you sure you want to delete this transaction?'),
                              actions: [
                                TextButton(onPressed: () => ctx.pop(false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => ctx.pop(true),
                                  child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await ref.read(transactionApiProvider).deleteTransaction(tx.id);
                            ref.invalidate(dashboardSummaryProvider);
                            ref.invalidate(recentTransactionsProvider);
                            if (context.mounted) context.pop();
                          }
                        },
                        icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                        label: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: theme.colorScheme.error.withValues(alpha: 0.5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Details card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Transaction Details', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _DetailRow(label: 'Category', value: tx.categoryName ?? 'Unknown'),
                      _DetailRow(label: 'Payment Method', value: (tx.paymentMethod ?? 'N/A').toUpperCase()),
                      _DetailRow(label: 'Account', value: tx.accountName ?? 'Unknown'),
                      _DetailRow(label: 'Type', value: tx.type.toUpperCase()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Description card
                if (tx.description != null && tx.description!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(tx.description!, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // History timeline
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('History', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 16),
                      _TimelineItem(
                        icon: Icons.add_circle_outline,
                        title: 'Created by ${tx.source == 'sms' ? 'SMS Parser' : 'Manual Entry'}',
                        subtitle: DateFormat('dd MMM yyyy, hh:mm a').format(tx.createdAt),
                        isFirst: true,
                      ),
                      if (tx.isConfirmed)
                        _TimelineItem(
                          icon: Icons.check_circle_outline,
                          title: 'Confirmed',
                          subtitle: 'Transaction verified',
                          isFirst: false,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isFirst;

  const _TimelineItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            if (!isFirst)
              const SizedBox.shrink()
            else
              Container(
                width: 1,
                height: 24,
                color: theme.colorScheme.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              Text(subtitle, style: theme.textTheme.bodySmall),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
