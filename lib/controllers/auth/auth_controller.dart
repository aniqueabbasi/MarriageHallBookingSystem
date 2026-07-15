import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/auth_client.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/auth/auth_user.dart';
import 'package:marriage_hall_app/models/auth/login_request.dart';
import 'package:marriage_hall_app/models/auth/register_request.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/services/storage_service.dart';

enum AuthStatus { idle, loading, success, error }

/// Whether there's a live, persisted session — distinct from [AuthStatus],
/// which only tracks the transient login/register call itself.
enum SessionStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final AuthUser? user;
  final SessionStatus session;

  /// Role for a session restored from storage, where only the token (and
  /// this) survive — [user] is only populated right after a fresh login.
  final UserRole? role;

  const AuthState({
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.user,
    this.session = SessionStatus.unknown,
    this.role,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => session == SessionStatus.authenticated;

  /// The role to route on, regardless of whether this state came from a
  /// fresh login (via [user]) or a restored session (via [role]).
  UserRole? get effectiveRole => user?.role ?? role;

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    AuthUser? user,
    SessionStatus? session,
    UserRole? role,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
      session: session ?? this.session,
      role: role ?? this.role,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required UserRole role,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      await ref
          .read(authClientProvider)
          .register(
            RegisterRequest(
              fullName: fullName,
              email: email,
              password: password,
              phoneNumber: phoneNumber,
              role: role,
            ),
          );
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await ref
          .read(authClientProvider)
          .login(LoginRequest(email: email, password: password));

      final storage = ref.read(storageServiceProvider);
      await storage.saveToken(response.accessToken);
      await storage.saveUserRole(response.user.role.apiRole);

      state = AuthState(
        status: AuthStatus.success,
        user: response.user,
        session: SessionStatus.authenticated,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(storageServiceProvider).clearToken();
    state = const AuthState(session: SessionStatus.unauthenticated);
  }

  /// Called once from splash on app start to restore (or reject) a
  /// persisted session.
  Future<void> loadSession() async {
    final storage = ref.read(storageServiceProvider);
    final token = await storage.getToken();

    if (token == null || _isJwtExpired(token)) {
      await storage.clearToken();
      state = const AuthState(session: SessionStatus.unauthenticated);
      return;
    }

    final roleValue = await storage.getUserRole();
    final role = roleValue == null ? null : UserRoleX.fromApiRole(roleValue);
    state = AuthState(session: SessionStatus.authenticated, role: role);
  }

  /// Invoked by the API layer when a request comes back 401 — the token is
  /// already gone (cleared by the caller) by the time this runs, this just
  /// reflects that into app state so the UI routes to login.
  void handleUnauthorized() {
    state = const AuthState(session: SessionStatus.unauthenticated);
  }

  bool _isJwtExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))))
              as Map<String, dynamic>;
      final exp = payload['exp'];
      if (exp is! int) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
        isUtc: true,
      );
      return DateTime.now().toUtc().isAfter(expiry);
    } catch (_) {
      return false;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
