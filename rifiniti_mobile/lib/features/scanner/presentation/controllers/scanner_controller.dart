import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/dio_client.dart';
import '../../../assets/domain/entities/asset.dart';
import '../../data/datasources/scanner_remote_datasource.dart';
import '../../data/repositories/scanner_repository_impl.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../../domain/usecases/fetch_item_by_barcode_usecase.dart';

/// Scanner state.
class ScannerState {
  final bool isScanning;
  final bool isLoading;
  final String? scannedCode;
  final Asset? foundAsset;
  final String? error;
  final bool flashEnabled;

  const ScannerState({
    this.isScanning = true,
    this.isLoading = false,
    this.scannedCode,
    this.foundAsset,
    this.error,
    this.flashEnabled = false,
  });

  ScannerState copyWith({
    bool? isScanning,
    bool? isLoading,
    String? scannedCode,
    Asset? foundAsset,
    String? error,
    bool? flashEnabled,
  }) {
    return ScannerState(
      isScanning: isScanning ?? this.isScanning,
      isLoading: isLoading ?? this.isLoading,
      scannedCode: scannedCode ?? this.scannedCode,
      foundAsset: foundAsset,
      error: error,
      flashEnabled: flashEnabled ?? this.flashEnabled,
    );
  }

  @override
  String toString() =>
      'ScannerState(isScanning: $isScanning, isLoading: $isLoading, code: $scannedCode)';
}

/// Provider for ScannerRepository.
final scannerRepositoryProvider = Provider<ScannerRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ScannerRepositoryImpl(
    remoteDataSource: ScannerRemoteDataSourceImpl(dioClient),
  );
});

/// Provider for FetchItemByBarcodeUseCase.
final fetchItemByBarcodeUseCaseProvider =
    Provider<FetchItemByBarcodeUseCase>((ref) {
  final repository = ref.watch(scannerRepositoryProvider);
  return FetchItemByBarcodeUseCase(repository);
});

/// Provider for ScannerController.
final scannerControllerProvider =
    StateNotifierProvider<ScannerController, ScannerState>((ref) {
  final fetchItemUseCase = ref.watch(fetchItemByBarcodeUseCaseProvider);
  return ScannerController(fetchItemUseCase: fetchItemUseCase);
});

/// Scanner controller using Riverpod StateNotifier.
class ScannerController extends StateNotifier<ScannerState> {
  final FetchItemByBarcodeUseCase _fetchItemUseCase;

  ScannerController({
    required FetchItemByBarcodeUseCase fetchItemUseCase,
  })  : _fetchItemUseCase = fetchItemUseCase,
        super(const ScannerState());

  /// Handle barcode scanned.
  Future<void> onBarcodeScanned(String code) async {
    // Prevent duplicate scans while loading
    if (state.isLoading) return;

    // Prevent scanning the same code repeatedly
    if (state.scannedCode == code && state.foundAsset != null) return;

    state = state.copyWith(
      isScanning: false,
      isLoading: true,
      scannedCode: code,
      error: null,
    );

    final result = await _fetchItemUseCase(code);

    result.fold(
      onSuccess: (asset) {
        state = state.copyWith(
          isLoading: false,
          foundAsset: asset,
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

  /// Resume scanning.
  void resumeScanning() {
    state = const ScannerState(isScanning: true);
  }

  /// Toggle flash.
  void toggleFlash() {
    state = state.copyWith(flashEnabled: !state.flashEnabled);
  }

  /// Clear error.
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset scanner state.
  void reset() {
    state = const ScannerState();
  }
}

/// Provider for the last scanned asset (for passing between pages).
final lastScannedAssetProvider = StateProvider<Asset?>((ref) => null);
