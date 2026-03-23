import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/user.dart';
import 'api_provider.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    debugPrint('AUTH CHECK: reading tokens from storage...');
    final client = _ref.read(apiClientProvider);
    final hasToken = await client.hasTokens();
    debugPrint('AUTH CHECK: jwt_token = ${hasToken ? "EXISTS" : "NULL"}');

    if (hasToken) {
      try {
        debugPrint('AUTH CHECK: calling /auth/me...');
        final authApi = _ref.read(authApiProvider);
        final user = await authApi.me();
        debugPrint('AUTH CHECK: /auth/me SUCCESS — user=${user.name}');
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } catch (e) {
        debugPrint('AUTH CHECK: /auth/me FAILED — $e');
        debugPrint('AUTH CHECK: attempting token refresh...');
        // Try refresh before giving up
        try {
          final refreshToken = await client.getRefreshToken();
          if (refreshToken != null) {
            final authApi = _ref.read(authApiProvider);
            final response = await authApi.refresh(refreshToken);
            final tokens = response['tokens'] as Map<String, dynamic>;
            await client.saveTokens(
              tokens['access_token'] as String,
              tokens['refresh_token'] as String,
            );
            debugPrint('AUTH CHECK: refresh SUCCESS, retrying /auth/me...');
            final user = await authApi.me();
            debugPrint('AUTH CHECK: /auth/me after refresh SUCCESS — user=${user.name}');
            state = AuthState(
              status: AuthStatus.authenticated,
              user: user,
            );
            return;
          }
        } catch (refreshError) {
          debugPrint('AUTH CHECK: refresh FAILED — $refreshError');
        }
        await client.clearTokens();
        debugPrint('AUTH CHECK: tokens cleared, setting UNAUTHENTICATED');
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      debugPrint('AUTH CHECK: no tokens found, setting UNAUTHENTICATED');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authApi = _ref.read(authApiProvider);
      final client = _ref.read(apiClientProvider);

      debugPrint('AUTH LOGIN: calling /auth/login...');
      final response = await authApi.login(email: email, password: password);
      final tokens = response['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['access_token'] as String;
      final refreshToken = tokens['refresh_token'] as String;

      debugPrint('AUTH LOGIN: saving tokens to secure storage...');
      await client.saveTokens(accessToken, refreshToken);

      // Verify tokens were saved
      final saved = await client.hasTokens();
      debugPrint('AUTH LOGIN: tokens saved = $saved');

      final user = User.fromJson(response['user'] as Map<String, dynamic>);
      debugPrint('AUTH LOGIN: SUCCESS — user=${user.name}');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      debugPrint('AUTH LOGIN: FAILED — $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authApi = _ref.read(authApiProvider);
      final client = _ref.read(apiClientProvider);

      debugPrint('AUTH REGISTER: calling /auth/register...');
      final response = await authApi.register(
        name: name,
        email: email,
        password: password,
      );
      final tokens = response['tokens'] as Map<String, dynamic>;
      final accessToken = tokens['access_token'] as String;
      final refreshToken = tokens['refresh_token'] as String;

      debugPrint('AUTH REGISTER: saving tokens to secure storage...');
      await client.saveTokens(accessToken, refreshToken);

      final saved = await client.hasTokens();
      debugPrint('AUTH REGISTER: tokens saved = $saved');

      final user = User.fromJson(response['user'] as Map<String, dynamic>);
      debugPrint('AUTH REGISTER: SUCCESS — user=${user.name}');
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      debugPrint('AUTH REGISTER: FAILED — $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    debugPrint('AUTH LOGOUT: clearing tokens...');
    final client = _ref.read(apiClientProvider);
    await client.clearTokens();
    debugPrint('AUTH LOGOUT: done, setting UNAUTHENTICATED');
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
