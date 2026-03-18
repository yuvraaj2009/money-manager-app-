import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/category.dart';
import '../../../domain/models/account.dart';
import '../../../domain/models/transaction.dart';
import '../../../shared/providers/api_provider.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.watch(categoryApiProvider);
  return api.getCategories();
});

final accountsProvider = FutureProvider<List<Account>>((ref) async {
  final api = ref.watch(accountApiProvider);
  return api.getAccounts();
});

final transactionDetailProvider =
    FutureProvider.family<Transaction, String>((ref, id) async {
  final api = ref.watch(transactionApiProvider);
  final txs = await api.getTransactions();
  return txs.firstWhere((t) => t.id == id);
});
