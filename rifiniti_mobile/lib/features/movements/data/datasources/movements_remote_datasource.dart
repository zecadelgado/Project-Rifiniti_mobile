import 'package:dio/dio.dart';

import '../../../../core/config/endpoints.dart';
import '../../../../core/config/env.dart';
import '../../../../core/network/dio_client.dart';
import '../models/movement_dto.dart';

/// Remote data source for movements.
abstract class MovementsRemoteDataSource {
  /// Get list of movements.
  Future<List<MovementDto>> getMovements({
    int? limit,
    int? offset,
    int? assetId,
  });

  /// Get movement by ID.
  Future<MovementDto> getMovementById(int id);

  /// Create a new movement.
  Future<MovementDto> createMovement(CreateMovementDto dto);
}

/// Implementation of [MovementsRemoteDataSource].
class MovementsRemoteDataSourceImpl implements MovementsRemoteDataSource {
  final DioClient _client;

  MovementsRemoteDataSourceImpl(this._client);

  @override
  Future<List<MovementDto>> getMovements({
    int? limit,
    int? offset,
    int? assetId,
  }) async {
    if (!Env.isApiConfigured) {
      return _mockGetMovements();
    }

    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (assetId != null) queryParams['asset_id'] = assetId;

      final response = await _client.get<Map<String, dynamic>>(
        Endpoints.movements,
        queryParameters: queryParams,
      );

      if (response.data == null) {
        return [];
      }

      final data = response.data!['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => MovementDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      if (Env.isDev) {
        return _mockGetMovements();
      }
      rethrow;
    }
  }

  @override
  Future<MovementDto> getMovementById(int id) async {
    if (!Env.isApiConfigured) {
      final movements = await _mockGetMovements();
      return movements.firstWhere(
        (m) => m.id == id,
        orElse: () => movements.first,
      );
    }

    try {
      final response = await _client.get<Map<String, dynamic>>(
        Endpoints.movementById(id),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response',
        );
      }

      return MovementDto.fromJson(response.data!);
    } on DioException {
      if (Env.isDev) {
        final movements = await _mockGetMovements();
        return movements.first;
      }
      rethrow;
    }
  }

  @override
  Future<MovementDto> createMovement(CreateMovementDto dto) async {
    if (!Env.isApiConfigured) {
      return _mockCreateMovement(dto);
    }

    try {
      final response = await _client.post<Map<String, dynamic>>(
        Endpoints.createMovement,
        data: dto.toJson(),
      );

      if (response.data == null) {
        throw DioException(
          requestOptions: response.requestOptions,
          message: 'Empty response',
        );
      }

      return MovementDto.fromJson(response.data!);
    } on DioException {
      if (Env.isDev) {
        return _mockCreateMovement(dto);
      }
      rethrow;
    }
  }

  // ============================================================
  // MOCK DATA
  // ============================================================

  Future<List<MovementDto>> _mockGetMovements() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      MovementDto(
        id: 1,
        assetId: 1,
        assetCode: '123456',
        assetName: 'Notebook Dell Latitude',
        type: 'transferencia',
        date: DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        originSectorName: 'TI',
        originLocationName: 'Sala 101',
        destinationSectorName: 'Administrativo',
        destinationLocationName: 'Sala 201',
        responsible: 'João Silva',
        reason: 'Realocação de equipamento',
        userName: 'Admin',
      ),
      MovementDto(
        id: 2,
        assetId: 2,
        assetCode: '789012',
        assetName: 'Monitor LG 27"',
        type: 'emprestimo',
        date: DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
        originSectorName: 'TI',
        originLocationName: 'Sala 101',
        destinationSectorName: 'RH',
        destinationLocationName: 'Sala 301',
        responsible: 'Maria Santos',
        reason: 'Empréstimo temporário',
        userName: 'Admin',
      ),
      MovementDto(
        id: 3,
        assetId: 3,
        assetCode: '345678',
        assetName: 'Cadeira Ergonômica',
        type: 'manutencao',
        date: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        originSectorName: 'Administrativo',
        originLocationName: 'Sala 201',
        destinationSectorName: 'Manutenção',
        destinationLocationName: 'Oficina',
        responsible: 'Carlos Oliveira',
        reason: 'Reparo no mecanismo de altura',
        userName: 'Admin',
      ),
    ];
  }

  Future<MovementDto> _mockCreateMovement(CreateMovementDto dto) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return MovementDto(
      id: DateTime.now().millisecondsSinceEpoch,
      assetId: dto.assetId,
      type: dto.type,
      date: dto.date,
      destinationSectorId: dto.destinationSectorId,
      destinationLocationId: dto.destinationLocationId,
      responsible: dto.responsible,
      reason: dto.reason,
      notes: dto.notes,
      userName: 'Usuário',
      createdAt: DateTime.now().toIso8601String(),
    );
  }
}
