import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/providers/api_provider.dart';
import '../providers/report_provider.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  Future<void> _showCreateBudgetDialog() async {
    final amountController = TextEditingController();
    final now = DateTime.now();
    final monthStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Monthly Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Set your total budget for ${_monthName(now.month)} ${now.year}',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                prefixText: 'Rs ',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (confirmed != true || amountController.text.isEmpty) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid amount')),
        );
      }
      return;
    }

    try {
      final budgetApi = ref.read(budgetApiProvider);
      await budgetApi.create(amount: amount, month: monthStr);
      // Refresh the report
      ref.invalidate(monthlyReportProvider((year: now.year, month: now.month)));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Budget of ${CurrencyFormatter.format(amount)} created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create budget: $e')),
        );
      }
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final report = ref.watch(monthlyReportProvider((year: now.year, month: now.month)));

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(monthlyReportProvider((year: now.year, month: now.month)));
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Ledger', style: theme.textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(
                      '${months[now.month - 1]} ${now.year}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Budget summary
              report.when(
                data: (data) {
                  final totalExpenses = (data['total_expenses'] as num?)?.toDouble() ?? 0;
                  final totalIncome = (data['total_income'] as num?)?.toDouble() ?? 0;
                  final savings = totalIncome - totalExpenses;
                  final categoryBreakdown = data['category_breakdown'] as List<dynamic>? ?? [];

                  return Column(
                    children: [
                      // Remaining budget card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'REMAINING BUDGET',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                CurrencyFormatter.format(savings > 0 ? savings : 0),
                                style: GoogleFonts.manrope(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: _showCreateBudgetDialog,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Create Budget'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Spending Categories
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text('Spending Categories', style: theme.textTheme.headlineSmall),
                      ),
                      const SizedBox(height: 12),
                      ...categoryBreakdown.take(8).map((cat) {
                        final c = cat as Map<String, dynamic>;
                        final name = c['category_name'] as String? ?? 'Unknown';
                        final amount = (c['amount'] as num?)?.toDouble() ?? 0;
                        final pct = (c['percentage'] as num?)?.toDouble() ?? 0;
                        final isOver = pct > 80;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(name, style: theme.textTheme.titleSmall)),
                                    Text(
                                      CurrencyFormatter.formatCompact(amount),
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: (pct / 100).clamp(0.0, 1.0),
                                          minHeight: 6,
                                          backgroundColor: theme.colorScheme.surfaceContainerHigh,
                                          valueColor: AlwaysStoppedAnimation(
                                            isOver
                                                ? (isDark ? AppTheme.expenseRedDark : AppTheme.expenseRed)
                                                : (isDark ? AppTheme.incomeGreenDark : AppTheme.incomeGreen),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isOver ? 'Over Budget' : 'Safe',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isOver
                                            ? (isDark ? AppTheme.expenseRedDark : AppTheme.expenseRed)
                                            : (isDark ? AppTheme.incomeGreenDark : AppTheme.incomeGreen),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Total Savings card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: (isDark ? AppTheme.incomeGreenDark : AppTheme.incomeGreen).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: (isDark ? AppTheme.incomeGreenDark : AppTheme.incomeGreen).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.savings_outlined,
                                color: isDark ? AppTheme.incomeGreenDark : AppTheme.incomeGreen,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Total Savings', style: theme.textTheme.titleSmall),
                                  Text(
                                    CurrencyFormatter.format(savings > 0 ? savings : 0),
                                    style: GoogleFonts.manrope(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppTheme.incomeGreenDark : AppTheme.incomeGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('Error loading report: $e'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
