import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../assets/domain/entities/asset.dart';
import '../repositories/scanner_repository.dart';

/// Use case for fetching an item by barcode.
class FetchItemByBarcodeUseCase {
  final ScannerRepository _repository;

  FetchItemByBarcodeUseCase(this._repository);

  /// Execute fetch item by barcode.
  Future<Result<Asset>> call(String code) async {
    // Validate code
    if (code.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Código não pode estar vazio'),
      );
    }

    if (code.length < 3) {
      return const Result.failure(
        ValidationFailure(message: 'Código deve ter pelo menos 3 caracteres'),
      );
    }

    // Fetch from repository
    final result = await _repository.fetchItemByBarcode(code);

    // Save to history regardless of result
    result.fold(
      onSuccess: (asset) => _repository.saveScanHistory(code, asset),
      onFailure: (_) => _repository.saveScanHistory(code, null),
    );

    return result;
  }
}
