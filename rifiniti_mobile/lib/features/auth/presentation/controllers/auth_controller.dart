import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

/// Authentication state.
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  String toString() =>
      'AuthState(isLoading: $isLoading, isAuthenticated: $isAuthenticated, user: $user)';
}

/// Provider for AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  return AuthRepositoryImpl(
    remoteDataSource: AuthRemoteDataSourceImpl(dioClient),
    secureStorage: secureStorage,
  );
});

/// Provider for LoginUseCase.
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

/// Provider for LogoutUseCase.
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

/// Provider for AuthController.
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final repository = ref.watch(authRepositoryProvider);

  return AuthController(
    loginUseCase: loginUseCase,
    logoutUseCase: logoutUseCase,
    repository: repository,
  );
});

/// Authentication controller using Riverpod StateNotifier.
class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _repository;

  AuthController({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository repository,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _repository = repository,
        super(const AuthState());

  /// Check if user is already authenticated (on app start).
  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final isAuthenticated = await _repository.isAuthenticated();

      if (isAuthenticated) {
        final result = await _repository.getCurrentUser();
        result.fold(
          onSuccess: (user) {
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: true,
              user: user,
            );
          },
          onFailure: (failure) {
            // Token might be invalid, clear auth
            _repository.clearAuth();
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: false,
            );
          },
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: 'Erro ao verificar autenticação',
      );
    }
  }

  /// Login with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUseCase(email: email, password: password);

    return result.fold(
      onSuccess: (authToken) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: authToken.user,
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: failure.message,
        );
        return false;
      },
    );
  }

  /// Logout current user.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    await _logoutUseCase();

    state = const AuthState(
      isLoading: false,
      isAuthenticated: false,
    );
  }

  /// Clear error message.
  void clearError() {
    state = state.copyWith(error: null);
  }
}
