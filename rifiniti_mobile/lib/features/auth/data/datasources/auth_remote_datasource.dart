import 'package:dio/dio.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_token_dto.dart';

/// Remote data source for authentication.
/// Handles API calls for auth operations.
abstract class AuthRemoteDataSource {
  /// Login with email and password.
  Future<AuthTokenDto> login({
    required String email,
    required String password,
  });

  /// Logout current user.
  Future<void> logout();

  /// Get current user data.
  Future<UserDto> getCurrentUser();
}

/// Implementation of [AuthRemoteDataSource].
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthTokenDto> login({
    required String email,
    required String password,
  }) async {
    // TODO: Connect to real Rifiniti Desk API when available
    // Check if API is configured
    if (!Env.isApiConfigured) {
      print('[AuthRemoteDataSource] API not configured, using mock data');
      return _mockLogin(email, password);
    }

    try {
      final response = await _client.post<Map<String, dynamic>>(
        Endpoints.login,
        data: {
          'email': email,
          'senha': password, // Using 'senha' to match desktop app
        },
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response from server',
        );
      }

      return AuthTokenDto.fromJson(response.data!);
    } on DioException {
      // If API fails, fallback to mock for development
      if (Env.isDev) {
        print('[AuthRemoteDataSource] API call failed, using mock fallback');
        return _mockLogin(email, password);
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    if (!Env.isApiConfigured) {
      print('[AuthRemoteDataSource] API not configured, mock logout');
      return;
    }

    try {
      await _client.post(Endpoints.logout);
    } catch (e) {
      // Logout should succeed even if API fails
      print('[AuthRemoteDataSource] Logout API call failed: $e');
    }
  }

  @override
  Future<UserDto> getCurrentUser() async {
    if (!Env.isApiConfigured) {
      print('[AuthRemoteDataSource] API not configured, using mock user');
      return _mockUser();
    }

    try {
      final response = await _client.get<Map<String, dynamic>>(Endpoints.me);

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response from server',
        );
      }

      return UserDto.fromJson(response.data!);
    } on DioException {
      if (Env.isDev) {
        return _mockUser();
      }
      rethrow;
    }
  }

  // ============================================================
  // MOCK DATA (for development without backend)
  // ============================================================

  /// Mock login for development.
  Future<AuthTokenDto> _mockLogin(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simple validation for mock
    if (email.isEmpty || password.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: Endpoints.login),
        response: Response(
          requestOptions: RequestOptions(path: Endpoints.login),
          statusCode: 401,
          data: {'message': 'E-mail ou senha inválidos'},
        ),
        type: DioExceptionType.badResponse,
      );
    }

    // Accept any email/password for development
    return AuthTokenDto(
      token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock_refresh_token',
      expiresAt: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      user: UserDto(
        id: 1,
        email: email,
        name: email.split('@').first.replaceAll('.', ' '),
        role: 'user',
      ),
    );
  }

  /// Mock user for development.
  UserDto _mockUser() {
    return const UserDto(
      id: 1,
      email: 'usuario@rifiniti.com',
      name: 'Usuário Teste',
      role: 'user',
    );
  }
}
