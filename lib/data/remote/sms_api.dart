import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/models/transaction.dart';

class SmsApi {
  final ApiClient _client;

  SmsApi(this._client);

  Future<Map<String, dynamic>> parseSms(
    String smsBody, {
    String? sender,
    String? timestamp,
  }) async {
    // timestamp is required by backend — default to current ISO time
    final ts = timestamp ?? DateTime.now().toIso8601String();
    final data = <String, dynamic>{
      'sms_body': smsBody,
      'timestamp': ts,
    };
    if (sender != null && sender.isNotEmpty) {
      data['sender'] = sender;
    }
    return await _client.post(ApiEndpoints.smsParse, data: data);
  }

  Future<Map<String, dynamic>> batchParse(List<Map<String, String>> messages) async {
    return await _client.post(
      ApiEndpoints.smsBatch,
      data: {
        'messages': messages.map((m) => {
          'sms_body': m['body'] ?? '',
          'timestamp': m['timestamp'] ?? DateTime.now().toIso8601String(),
          'sender': m['sender'],
        }).toList(),
      },
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
    return Transaction.fromJson(response);
  }

  Future<void> reject(String id) async {
    await _client.put(ApiEndpoints.smsReject(id));
  }
}
