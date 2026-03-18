import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/models/transaction.dart';
import '../../domain/models/transaction_summary.dart';

class TransactionApi {
  final ApiClient _client;

  TransactionApi(this._client);

  Future<List<Transaction>> getTransactions({
    String? type,
    String? categoryId,
    String? accountId,
    String? startDate,
    String? endDate,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, dynamic>{};
    if (type != null) queryParams['type'] = type;
    if (categoryId != null) queryParams['category_id'] = categoryId;
    if (accountId != null) queryParams['account_id'] = accountId;
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;
    if (limit != null) queryParams['limit'] = limit;
    if (offset != null) queryParams['offset'] = offset;

    final response = await _client.get(
      ApiEndpoints.transactions,
      queryParameters: queryParams,
    );
    final items = response['transactions'] as List<dynamic>;
    return items
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Transaction> createTransaction({
    required double amount,
    required String type,
    required String categoryId,
    required String accountId,
    String? description,
    String? paymentMethod,
    required DateTime date,
  }) async {
    final response = await _client.post(
      ApiEndpoints.transactions,
      data: {
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'account_id': accountId,
        'description': description,
        'payment_method': paymentMethod,
        'date': date.toIso8601String(),
      },
    );
    return Transaction.fromJson(response['transaction'] as Map<String, dynamic>);
  }

  Future<Transaction> updateTransaction(
    String id, {
    double? amount,
    String? type,
    String? categoryId,
    String? accountId,
    String? description,
    String? paymentMethod,
    DateTime? date,
  }) async {
    final data = <String, dynamic>{};
    if (amount != null) data['amount'] = amount;
    if (type != null) data['type'] = type;
    if (categoryId != null) data['category_id'] = categoryId;
    if (accountId != null) data['account_id'] = accountId;
    if (description != null) data['description'] = description;
    if (paymentMethod != null) data['payment_method'] = paymentMethod;
    if (date != null) data['date'] = date.toIso8601String();

    final response = await _client.put(
      '${ApiEndpoints.transactions}/$id',
      data: data,
    );
    return Transaction.fromJson(response['transaction'] as Map<String, dynamic>);
  }

  Future<void> deleteTransaction(String id) async {
    await _client.delete('${ApiEndpoints.transactions}/$id');
  }

  Future<TransactionSummary> getSummary({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (startDate != null) queryParams['start_date'] = startDate;
    if (endDate != null) queryParams['end_date'] = endDate;

    final response = await _client.get(
      ApiEndpoints.transactionSummary,
      queryParameters: queryParams,
    );
    return TransactionSummary.fromJson(response);
  }
}
