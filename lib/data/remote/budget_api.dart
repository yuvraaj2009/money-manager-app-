import '../../core/network/api_client.dart';

class BudgetApi {
  final ApiClient _client;

  BudgetApi(this._client);

  Future<List<Map<String, dynamic>>> list({String? month}) async {
    final params = <String, dynamic>{};
    if (month != null) params['month'] = month;
    final response = await _client.get('/budgets', queryParameters: params);
    final budgets = response['budgets'] as List<dynamic>;
    return budgets.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create({
    required double amount,
    required String month,
    String? categoryId,
  }) async {
    return await _client.post('/budgets', data: {
      'amount': amount,
      'month': month,
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  Future<Map<String, dynamic>> update(String id, {required double amount}) async {
    return await _client.put('/budgets/$id', data: {'amount': amount});
  }

  Future<void> delete(String id) async {
    await _client.delete('/budgets/$id');
  }
}
