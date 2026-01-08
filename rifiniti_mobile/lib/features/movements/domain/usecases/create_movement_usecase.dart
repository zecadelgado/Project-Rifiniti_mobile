import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/movement.dart';
import '../repositories/movements_repository.dart';

/// Use case for creating a movement.
class CreateMovementUseCase {
  final MovementsRepository _repository;

  CreateMovementUseCase(this._repository);

  /// Execute create movement.
  Future<Result<Movement>> call({
    required int assetId,
    required MovementType type,
    required DateTime date,
    int? destinationSectorId,
    int? destinationLocationId,
    String? responsible,
    String? reason,
    String? notes,
  }) async {
    // Validate inputs
    if (assetId <= 0) {
      return const Result.failure(
        ValidationFailure(message: 'Ativo inválido'),
      );
    }

    return _repository.createMovement(
      assetId: assetId,
      type: type,
      date: date,
      destinationSectorId: destinationSectorId,
      destinationLocationId: destinationLocationId,
      responsible: responsible,
      reason: reason,
      notes: notes,
    );
  }
}
