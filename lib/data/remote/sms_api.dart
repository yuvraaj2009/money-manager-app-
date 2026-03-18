import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/models/transaction.dart';

class SmsApi {
  final ApiClient _client;

  SmsApi(this._client);

  Future<Map<String, dynamic>> parseSms(String smsBody) async {
    return await _client.post(
      ApiEndpoints.smsParse,
      data: {'sms_body': smsBody},
    );
  }

  Future<Map<String, dynamic>> batchParse(List<String> messages) async {
    return await _client.post(
      ApiEndpoints.smsBatch,
      data: {'messages': messages},
    );
  }

  Future<List<Transaction>> getPending() async {
    final response = await _client.get(ApiEndpoints.smsPending);
    final items = response['transactions'] as List<dynamic>;
    return items
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Transaction> confirm(String id) async {
    final response = await _client.post(ApiEndpoints.smsConfirm(id));
    return Transaction.fromJson(response['transaction'] as Map<String, dynamic>);
  }

  Future<void> reject(String id) async {
    await _client.put(ApiEndpoints.smsReject(id));
  }
}
