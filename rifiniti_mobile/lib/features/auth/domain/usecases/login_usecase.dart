import '../../../../core/errors/result.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

/// Use case for user login.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login with email and password.
  Future<Result<AuthToken>> call({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'E-mail é obrigatório'),
      );
    }

    if (password.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Senha é obrigatória'),
      );
    }

    // Call repository
    return _repository.login(email: email, password: password);
  }
}

/// Validation failure for use case level validation.
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}
