import '../../../../core/errors/result.dart';
import '../entities/movement.dart';

/// Movements repository interface.
abstract class MovementsRepository {
  /// Get list of movements.
  Future<Result<List<Movement>>> getMovements({
    int? limit,
    int? offset,
    int? assetId,
  });

  /// Get movement by ID.
  Future<Result<Movement>> getMovementById(int id);

  /// Create a new movement.
  Future<Result<Movement>> createMovement({
    required int assetId,
    required MovementType type,
    required DateTime date,
    int? destinationSectorId,
    int? destinationLocationId,
    String? responsible,
    String? reason,
    String? notes,
  });
}
