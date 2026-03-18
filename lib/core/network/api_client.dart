import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../errors/app_exception.dart';
import 'api_endpoints.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _onRequest,
      onError: _onError,
    ));
  }

  Dio get dio => _dio;

  // ─── Token Management ───

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  // ─── Interceptors ───

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    if (error.response?.statusCode == 401) {
      // Try refresh
      final refreshToken = await getRefreshToken();
      if (refreshToken != null) {
        try {
          final response = await Dio(BaseOptions(
            baseUrl: AppConfig.apiBaseUrl,
          )).post(
            ApiEndpoints.refresh,
            data: {'refresh_token': refreshToken},
          );

          final data = response.data['data'];
          final newAccess = data['tokens']['access_token'] as String;
          final newRefresh = data['tokens']['refresh_token'] as String;
          await saveTokens(newAccess, newRefresh);

          // Retry original request
          final opts = error.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccess';
          final retryResponse = await _dio.fetch(opts);
          return handler.resolve(retryResponse);
        } catch (_) {
          await clearTokens();
          return handler.reject(error);
        }
      }
      await clearTokens();
    }
    handler.next(error);
  }

  // ─── Convenience Methods ───

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Map<String, dynamic> _handleResponse(Response response) {
    final body = response.data as Map<String, dynamic>;
    if (body['success'] == true) {
      return body['data'] as Map<String, dynamic>;
    }
    final error = body['error'] as Map<String, dynamic>? ?? {};
    throw ServerException(
      message: error['message'] as String? ?? 'Unknown error',
      code: error['code'] as String? ?? 'UNKNOWN',
      statusCode: response.statusCode,
    );
  }

  AppException _handleDioError(DioException e) {
    if (e.response != null) {
      final body = e.response?.data;
      if (body is Map<String, dynamic> && body['error'] != null) {
        final error = body['error'] as Map<String, dynamic>;
        return ServerException(
          message: error['message'] as String? ?? 'Server error',
          code: error['code'] as String? ?? 'SERVER_ERROR',
          statusCode: e.response?.statusCode,
        );
      }
      if (e.response?.statusCode == 401) {
        return AuthException();
      }
      return ServerException(
        message: 'Server error (${e.response?.statusCode})',
        statusCode: e.response?.statusCode,
      );
    }
    return NetworkException();
  }
}
