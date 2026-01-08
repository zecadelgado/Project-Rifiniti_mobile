import 'package:dio/dio.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../assets/domain/entities/asset.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_remote_datasource.dart';

/// Implementation of [ScannerRepository].
class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerRemoteDataSource _remoteDataSource;
  final HiveService _hiveService;

  ScannerRepositoryImpl({
    required ScannerRemoteDataSource remoteDataSource,
    HiveService? hiveService,
  })  : _remoteDataSource = remoteDataSource,
        _hiveService = hiveService ?? HiveService.instance;

  @override
  Future<Result<Asset>> fetchItemByBarcode(String code) async {
    try {
      final dto = await _remoteDataSource.fetchItemByBarcode(code);
      final asset = dto.toEntity();

      // Cache the asset locally
      await _hiveService.cacheAsset(code, dto.toJson());
      await _hiveService.saveLastScanned(dto.toJson());

      return Result.success(asset);
    } on DioException catch (e) {
      // Try to get from cache if offline
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        final cached = _hiveService.getCachedAsset(code);
        if (cached != null) {
          // Import the DTO class to convert cached data
          final dto = _createAssetFromCache(cached);
          return Result.success(dto);
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
  Future<void> saveScanHistory(String code, Asset? asset) async {
    final historyEntry = {
      'code': code,
      'asset_id': asset?.id,
      'asset_name': asset?.name,
      'scanned_at': DateTime.now().toIso8601String(),
      'found': asset != null,
    };

    // Save to Hive
    // TODO: Implement proper scan history storage
    print('[ScannerRepository] Saved scan history: $historyEntry');
  }

  @override
  Future<List<Map<String, dynamic>>> getScanHistory({int limit = 10}) async {
    // TODO: Implement proper scan history retrieval
    return [];
  }

  /// Create Asset from cached data.
  Asset _createAssetFromCache(Map<String, dynamic> cached) {
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
