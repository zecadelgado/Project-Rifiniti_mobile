import '../../../../core/errors/result.dart';
import '../entities/asset.dart';

/// Assets repository interface.
/// Defines the contract for asset-related operations.
abstract class AssetsRepository {
  /// Get asset by ID.
  Future<Result<Asset>> getAssetById(int id);

  /// Get asset by code (número patrimonial).
  Future<Result<Asset>> getAssetByCode(String code);

  /// Get list of assets with optional filters.
  Future<Result<List<Asset>>> getAssets({
    int? limit,
    int? offset,
    String? search,
    String? category,
    String? status,
    int? sectorId,
  });

  /// Get total count of assets.
  Future<Result<int>> getAssetsCount({
    String? search,
    String? category,
    String? status,
    int? sectorId,
  });
}
