import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/remote/auth_api.dart';
import '../../data/remote/transaction_api.dart';
import '../../data/remote/category_api.dart';
import '../../data/remote/account_api.dart';
import '../../data/remote/sms_api.dart';
import '../../data/remote/budget_api.dart';
import '../../data/remote/report_api.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final transactionApiProvider = Provider<TransactionApi>((ref) {
  return TransactionApi(ref.watch(apiClientProvider));
});

final categoryApiProvider = Provider<CategoryApi>((ref) {
  return CategoryApi(ref.watch(apiClientProvider));
});

final accountApiProvider = Provider<AccountApi>((ref) {
  return AccountApi(ref.watch(apiClientProvider));
});

final smsApiProvider = Provider<SmsApi>((ref) {
  return SmsApi(ref.watch(apiClientProvider));
});

final budgetApiProvider = Provider<BudgetApi>((ref) {
  return BudgetApi(ref.watch(apiClientProvider));
});

final reportApiProvider = Provider<ReportApi>((ref) {
  return ReportApi(ref.watch(apiClientProvider));
});
