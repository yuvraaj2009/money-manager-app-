import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/models/account.dart';

class AccountApi {
  final ApiClient _client;

  AccountApi(this._client);

  Future<List<Account>> getAccounts() async {
    final response = await _client.get(ApiEndpoints.accounts);
    final items = response['accounts'] as List<dynamic>;
    return items
        .map((e) => Account.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Account> createAccount({
    required String name,
    required String type,
    double balance = 0,
    String? bankIdentifier,
  }) async {
    final response = await _client.post(
      ApiEndpoints.accounts,
      data: {
        'name': name,
        'type': type,
        'balance': balance,
        'bank_identifier': bankIdentifier,
      },
    );
    return Account.fromJson(response['account'] as Map<String, dynamic>);
  }

  Future<Account> updateAccount(
    String id, {
    String? name,
    String? type,
    double? balance,
    String? bankIdentifier,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (type != null) data['type'] = type;
    if (balance != null) data['balance'] = balance;
    if (bankIdentifier != null) data['bank_identifier'] = bankIdentifier;

    final response = await _client.put(
      '${ApiEndpoints.accounts}/$id',
      data: data,
    );
    return Account.fromJson(response['account'] as Map<String, dynamic>);
  }

  Future<void> deleteAccount(String id) async {
    await _client.delete('${ApiEndpoints.accounts}/$id');
  }
}
