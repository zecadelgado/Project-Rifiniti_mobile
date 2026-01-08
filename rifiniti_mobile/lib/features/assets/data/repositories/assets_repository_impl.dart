import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/hive_service.dart';
import '../../domain/entities/asset.dart';
import '../../domain/repositories/assets_repository.dart';
import '../datasources/assets_remote_datasource.dart';

/// Implementation of [AssetsRepository].
class AssetsRepositoryImpl implements AssetsRepository {
  final AssetsRemoteDataSource _remoteDataSource;
  final HiveService _hiveService;

  AssetsRepositoryImpl({
    required AssetsRemoteDataSource remoteDataSource,
    HiveService? hiveService,
  })  : _remoteDataSource = remoteDataSource,
        _hiveService = hiveService ?? HiveService.instance;

  @override
  Future<Result<Asset>> getAssetById(int id) async {
    try {
      final dto = await _remoteDataSource.getAssetById(id);
      final asset = dto.toEntity();

      // Cache the asset
      await _hiveService.cacheAsset(asset.code, dto.toJson());

      return Result.success(asset);
    } on DioException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao buscar ativo: $e'),
      );
    }
  }

  @override
  Future<Result<Asset>> getAssetByCode(String code) async {
    try {
      final dto = await _remoteDataSource.getAssetByCode(code);
      final asset = dto.toEntity();

      // Cache the asset
      await _hiveService.cacheAsset(code, dto.toJson());

      return Result.success(asset);
    } on DioException catch (e) {
      // Try cache if offline
      if (e.type == DioExceptionType.connectionError) {
        final cached = _hiveService.getCachedAsset(code);
        if (cached != null) {
          return Result.success(_assetFromCache(cached));
        }
      }
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao buscar ativo: $e'),
      );
    }
  }

  @override
  Future<Result<List<Asset>>> getAssets({
    int? limit,
    int? offset,
    String? search,
    String? category,
    String? status,
    int? sectorId,
  }) async {
    try {
      final dtos = await _remoteDataSource.getAssets(
        limit: limit,
        offset: offset,
        search: search,
        category: category,
        status: status,
        sectorId: sectorId,
      );

      final assets = dtos.map((dto) => dto.toEntity()).toList();

      return Result.success(assets);
    } on DioException catch (e) {
      // Try cache if offline
      if (e.type == DioExceptionType.connectionError) {
        final cached = _hiveService.getAllCachedAssets();
        if (cached.isNotEmpty) {
          final assets = cached.map(_assetFromCache).toList();
          return Result.success(assets);
        }
      }
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao listar ativos: $e'),
      );
    }
  }

  @override
  Future<Result<int>> getAssetsCount({
    String? search,
    String? category,
    String? status,
    int? sectorId,
  }) async {
    try {
      final count = await _remoteDataSource.getAssetsCount(
        search: search,
        category: category,
        status: status,
        sectorId: sectorId,
      );
      return Result.success(count);
    } on DioException catch (e) {
      return Result.failure(e.toFailure());
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Erro ao contar ativos: $e'),
      );
    }
  }

  Asset _assetFromCache(Map<String, dynamic> cached) {
    return Asset(
      id: cached['id'] as int? ?? 0,
      code: cached['code'] as String? ?? '',
      name: cached['name'] as String? ?? '',
      description: cached['description'] as String?,
      serialNumber: cached['serial_number'] as String?,
      category: cached['category'] as String?,
      status: cached['status'] as String? ?? 'ativo',
      sectorId: cached['sector_id'] as int?,
      sectorName: cached['sector_name'] as String?,
      locationId: cached['location_id'] as int?,
      locationName: cached['location_name'] as String?,
      acquisitionDate: cached['acquisition_date'] != null
          ? DateTime.tryParse(cached['acquisition_date'] as String)
          : null,
      purchaseValue: (cached['purchase_value'] as num?)?.toDouble(),
      currentValue: (cached['current_value'] as num?)?.toDouble(),
      supplierId: cached['supplier_id'] as int?,
      supplierName: cached['supplier_name'] as String?,
    );
  }
}
