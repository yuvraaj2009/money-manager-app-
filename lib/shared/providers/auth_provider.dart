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
    final client = _ref.read(apiClientProvider);
    final hasTokens = await client.hasTokens();
    if (hasTokens) {
      try {
        final authApi = _ref.read(authApiProvider);
        final user = await authApi.me();
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
        );
      } catch (_) {
        await client.clearTokens();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authApi = _ref.read(authApiProvider);
      final client = _ref.read(apiClientProvider);

      final response = await authApi.login(email: email, password: password);
      final tokens = response['tokens'] as Map<String, dynamic>;
      await client.saveTokens(
        tokens['access_token'] as String,
        tokens['refresh_token'] as String,
      );

      final user = User.fromJson(response['user'] as Map<String, dynamic>);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
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

      final response = await authApi.register(
        name: name,
        email: email,
        password: password,
      );
      final tokens = response['tokens'] as Map<String, dynamic>;
      await client.saveTokens(
        tokens['access_token'] as String,
        tokens['refresh_token'] as String,
      );

      final user = User.fromJson(response['user'] as Map<String, dynamic>);
      state = AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    final client = _ref.read(apiClientProvider);
    await client.clearTokens();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});
