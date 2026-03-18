import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/transaction.dart';
import '../../../domain/models/transaction_summary.dart';
import '../../../shared/providers/api_provider.dart';

final dashboardSummaryProvider = FutureProvider<TransactionSummary>((ref) async {
  final api = ref.watch(transactionApiProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  return api.getSummary(
    startDate: startOfMonth.toIso8601String().split('T').first,
    endDate: now.toIso8601String().split('T').first,
  );
});

final recentTransactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final api = ref.watch(transactionApiProvider);
  return api.getTransactions(limit: 10);
});

final monthlyReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(reportApiProvider);
  final now = DateTime.now();
  return api.getMonthlyReport(now.year, now.month);
});
