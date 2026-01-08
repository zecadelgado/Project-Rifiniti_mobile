import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../../core/storage/sync_queue.dart';
import '../../domain/entities/movement.dart';
import '../../domain/repositories/movements_repository.dart';
import '../datasources/movements_remote_datasource.dart';
import '../models/movement_dto.dart';

/// Implementation of [MovementsRepository].
class MovementsRepositoryImpl implements MovementsRepository {
  final MovementsRemoteDataSource _remoteDataSource;
  final HiveService _hiveService;
  final SyncQueueService? _syncQueue;

  MovementsRepositoryImpl({
    required MovementsRemoteDataSource remoteDataSource,
    HiveService? hiveService,
    SyncQueueService? syncQueue,
  })  : _remoteDataSource = remoteDataSource,
        _hiveService = hiveService ?? HiveService.instance,
        _syncQueue = syncQueue;

  @override
  Future<Result<List<Movement>>> getMovements({
    int? limit,
    int? offset,
    int? assetId,
  }) async {
    try {
      final dtos = await _remoteDataSource.getMovements(
        limit: limit,
        offset: offset,
        assetId: assetId,
      );

      final movements = dtos.map((dto) => dto.toEntity()).toList();

      // Cache movements
      await _hiveService.cacheMovements(
        dtos.map((dto) => dto.toJson()).toList(),
      );

      return Result.success(movements);
    } on DioException catch (e) {
      // Try cache if offline
      if (e.type == DioExceptionType.connectionError) {
        final cached = _hiveService.getAllCachedMovements();
        if (cached.isNotEmpty) {
          final movements = cached
              .map((m) => MovementDto.fromJson(m).toEntity())
              .toList();
          return Result.success(movements);
        }
      }
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao listar movimentações: $e'),
      );
    }
  }

  @override
  Future<Result<Movement>> getMovementById(int id) async {
    try {
      final dto = await _remoteDataSource.getMovementById(id);
      return Result.success(dto.toEntity());
    } on DioException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao buscar movimentação: $e'),
      );
    }
  }

  @override
  Future<Result<Movement>> createMovement({
    required int assetId,
    required MovementType type,
    required DateTime date,
    int? destinationSectorId,
    int? destinationLocationId,
    String? responsible,
    String? reason,
    String? notes,
  }) async {
    final createDto = CreateMovementDto(
      assetId: assetId,
      type: type.value,
      date: date.toIso8601String(),
      destinationSectorId: destinationSectorId,
      destinationLocationId: destinationLocationId,
      responsible: responsible,
      reason: reason,
      notes: notes,
    );

    try {
      final dto = await _remoteDataSource.createMovement(createDto);
      final movement = dto.toEntity();

      // Cache the new movement
      await _hiveService.cacheMovement(movement.id, dto.toJson());

      return Result.success(movement);
    } on DioException catch (e) {
      // If offline, queue for later sync
      if (e.type == DioExceptionType.connectionError && _syncQueue != null) {
        await _syncQueue!.queueOperation(
          SyncOperation(
            type: SyncOperationType.createMovement,
            endpoint: '/movements',
            method: 'POST',
            data: createDto.toJson(),
          ),
        );

        // Return a temporary movement with pending status
        final tempMovement = Movement(
          id: -DateTime.now().millisecondsSinceEpoch,
          assetId: assetId,
          type: type,
          date: date,
          destinationSectorId: destinationSectorId,
          destinationLocationId: destinationLocationId,
          responsible: responsible,
          reason: reason,
          notes: notes,
        );

        return Result.success(tempMovement);
      }

      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao criar movimentação: $e'),
      );
    }
  }
}
