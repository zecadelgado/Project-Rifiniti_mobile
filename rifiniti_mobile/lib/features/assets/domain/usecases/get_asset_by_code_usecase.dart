import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../entities/asset.dart';
import '../repositories/assets_repository.dart';

/// Use case for getting an asset by its code.
class GetAssetByCodeUseCase {
  final AssetsRepository _repository;

  GetAssetByCodeUseCase(this._repository);

  /// Execute get asset by code.
  Future<Result<Asset>> call(String code) async {
    if (code.isEmpty) {
      return const Result.failure(
        ValidationFailure(message: 'Código não pode estar vazio'),
      );
    }

    return _repository.getAssetByCode(code);
  }
}
