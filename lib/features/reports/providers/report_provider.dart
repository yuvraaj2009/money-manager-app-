import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/api_provider.dart';

final categoryBreakdownProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(reportApiProvider);
  return api.getCategoryBreakdown();
});

final trendsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(reportApiProvider);
  return api.getTrends(months: 6);
});

final monthlyReportProvider = FutureProvider.family<Map<String, dynamic>, ({int year, int month})>(
  (ref, params) async {
    final api = ref.watch(reportApiProvider);
    return api.getMonthlyReport(params.year, params.month);
  },
);
