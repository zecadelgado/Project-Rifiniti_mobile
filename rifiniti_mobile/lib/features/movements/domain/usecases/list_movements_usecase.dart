import '../../../../core/errors/result.dart';
import '../entities/movement.dart';
import '../repositories/movements_repository.dart';

/// Use case for listing movements.
class ListMovementsUseCase {
  final MovementsRepository _repository;

  ListMovementsUseCase(this._repository);

  /// Execute list movements.
  Future<Result<List<Movement>>> call({
    int? limit,
    int? offset,
    int? assetId,
  }) async {
    return _repository.getMovements(
      limit: limit,
      offset: offset,
      assetId: assetId,
    );
  }
}
