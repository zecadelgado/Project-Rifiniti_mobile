import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

/// Use case for user logout.
class LogoutUseCase {
  final AuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout.
  Future<Result<bool>> call() async {
    return _repository.logout();
  }
}
