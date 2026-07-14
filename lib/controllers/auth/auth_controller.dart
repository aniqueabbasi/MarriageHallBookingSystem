import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:marriage_hall_app/api/clients/auth_client.dart';
import 'package:marriage_hall_app/constants/storage_keys.dart';
import 'package:marriage_hall_app/exceptions/api_exception.dart';
import 'package:marriage_hall_app/models/auth/auth_user.dart';
import 'package:marriage_hall_app/models/auth/login_request.dart';
import 'package:marriage_hall_app/models/auth/register_request.dart';
import 'package:marriage_hall_app/models/user_role.dart';
import 'package:marriage_hall_app/services/storage_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final AuthUser? user;

  const AuthState({this.status = AuthStatus.idle, this.errorMessage, this.user});

  bool get isLoading => status == AuthStatus.loading;
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
    state = const AuthState(status: AuthStatus.loading);

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
      state = const AuthState(status: AuthStatus.success);
      return true;
    } on ApiException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = const AuthState(status: AuthStatus.loading);

    try {
      final response = await ref
          .read(authClientProvider)
          .login(LoginRequest(email: email, password: password));

      final storage = ref.read(storageServiceProvider);
      await storage.write(StorageKeys.accessToken, response.accessToken);
      await storage.write(StorageKeys.refreshToken, response.refreshToken);

      state = AuthState(status: AuthStatus.success, user: response.user);
      return true;
    } on ApiException catch (e) {
      state = AuthState(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (_) {
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
      return false;
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
