import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../domain/models/user.dart';

class AuthApi {
  final ApiClient _client;

  AuthApi(this._client);

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.register,
      data: {'name': name, 'email': email, 'password': password},
    );
    return response;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return response;
  }

  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _client.post(
      ApiEndpoints.refresh,
      data: {'refresh_token': refreshToken},
    );
    return response;
  }

  Future<User> me() async {
    final response = await _client.get(ApiEndpoints.me);
    return User.fromJson(response['user'] as Map<String, dynamic>);
  }

  Future<void> verify() async {
    await _client.get(ApiEndpoints.verify);
  }
}
