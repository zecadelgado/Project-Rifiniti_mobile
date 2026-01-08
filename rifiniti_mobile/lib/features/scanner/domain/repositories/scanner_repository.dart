import '../../../../core/errors/result.dart';
import '../../../assets/domain/entities/asset.dart';

/// Scanner repository interface.
/// Defines the contract for scanner-related operations.
abstract class ScannerRepository {
  /// Fetch asset by barcode/QR code.
  /// Returns [Asset] on success or [Failure] on error.
  Future<Result<Asset>> fetchItemByBarcode(String code);

  /// Save scan history locally.
  Future<void> saveScanHistory(String code, Asset? asset);

  /// Get recent scan history.
  Future<List<Map<String, dynamic>>> getScanHistory({int limit = 10});
}
