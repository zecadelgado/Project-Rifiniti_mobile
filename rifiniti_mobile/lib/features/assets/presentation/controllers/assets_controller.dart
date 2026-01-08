import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/assets_remote_datasource.dart';
import '../../data/repositories/assets_repository_impl.dart';
import '../../domain/entities/asset.dart';
import '../../domain/repositories/assets_repository.dart';

/// Assets list state.
class AssetsState {
  final bool isLoading;
  final List<Asset> assets;
  final String? error;
  final String searchQuery;
  final String? selectedCategory;
  final String? selectedStatus;

  const AssetsState({
    this.isLoading = false,
    this.assets = const [],
    this.error,
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedStatus,
  });

  AssetsState copyWith({
    bool? isLoading,
    List<Asset>? assets,
    String? error,
    String? searchQuery,
    String? selectedCategory,
    String? selectedStatus,
  }) {
    return AssetsState(
      isLoading: isLoading ?? this.isLoading,
      assets: assets ?? this.assets,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

/// Provider for AssetsRepository.
final assetsRepositoryProvider = Provider<AssetsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AssetsRepositoryImpl(
    remoteDataSource: AssetsRemoteDataSourceImpl(dioClient),
  );
});

/// Provider for AssetsController.
final assetsControllerProvider =
    StateNotifierProvider<AssetsController, AssetsState>((ref) {
  final repository = ref.watch(assetsRepositoryProvider);
  return AssetsController(repository: repository);
});

/// Assets controller using Riverpod StateNotifier.
class AssetsController extends StateNotifier<AssetsState> {
  final AssetsRepository _repository;

  AssetsController({required AssetsRepository repository})
      : _repository = repository,
        super(const AssetsState());

  /// Load assets list.
  Future<void> loadAssets() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getAssets(
      limit: 50,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      category: state.selectedCategory,
      status: state.selectedStatus,
    );

    result.fold(
      onSuccess: (assets) {
        state = state.copyWith(
          isLoading: false,
          assets: assets,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
    );
  }

  /// Search assets.
  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query);
    await loadAssets();
  }

  /// Filter by category.
  Future<void> filterByCategory(String? category) async {
    state = state.copyWith(selectedCategory: category);
    await loadAssets();
  }

  /// Filter by status.
  Future<void> filterByStatus(String? status) async {
    state = state.copyWith(selectedStatus: status);
    await loadAssets();
  }

  /// Clear filters.
  Future<void> clearFilters() async {
    state = const AssetsState();
    await loadAssets();
  }

  /// Refresh assets list.
  Future<void> refresh() async {
    await loadAssets();
  }
}

/// Provider for single asset details.
final assetDetailsProvider =
    FutureProvider.family<Asset?, int>((ref, assetId) async {
  final repository = ref.watch(assetsRepositoryProvider);
  final result = await repository.getAssetById(assetId);
  return result.dataOrNull;
});
