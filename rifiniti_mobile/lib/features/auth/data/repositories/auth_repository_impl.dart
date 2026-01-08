import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository].
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = secureStorage;

  @override
  Future<Result<AuthToken>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      final authToken = dto.toEntity();

      // Save token and user data to secure storage
      await _secureStorage.saveToken(authToken.token);
      if (authToken.refreshToken != null) {
        await _secureStorage.saveRefreshToken(authToken.refreshToken!);
      }
      await _secureStorage.saveUserData(
        userId: authToken.user.id,
        email: authToken.user.email,
        name: authToken.user.name,
        role: authToken.user.role,
      );

      return Result.success(authToken);
    } on DioException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao fazer login: $e'),
      );
    }
  }

  @override
  Future<Result<bool>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _secureStorage.clearAuthData();
      return const Result.success(true);
    } on DioException catch (e) {
      // Even if API fails, clear local data
      await _secureStorage.clearAuthData();
      return Result.failure(e.toFailure());
    } catch (e) {
      await _secureStorage.clearAuthData();
      return Result.failure(
        UnknownFailure(message: 'Erro ao fazer logout: $e'),
      );
    }
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    try {
      final dto = await _remoteDataSource.getCurrentUser();
      return Result.success(dto.toEntity());
    } on DioException catch (e) {
      // Try to get from local storage
      final userId = await _secureStorage.getUserId();
      final email = await _secureStorage.getUserEmail();
      final name = await _secureStorage.getUserName();
      final role = await _secureStorage.getUserRole();

      if (userId != null && email != null && name != null) {
        return Result.success(User(
          id: userId,
          email: email,
          name: name,
          role: role,
        ));
      }

      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao obter usuário: $e'),
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _secureStorage.hasToken();
  }

  @override
  Future<String?> getToken() async {
    return _secureStorage.getToken();
  }

  @override
  Future<void> clearAuth() async {
    await _secureStorage.clearAuthData();
  }
}
