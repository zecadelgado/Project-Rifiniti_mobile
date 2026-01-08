import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/scanner_controller.dart';
import '../widgets/scanner_overlay.dart';

/// Scanner page for reading barcodes and QR codes.
class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({super.key});

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  MobileScannerController? _scannerController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    // Handle the scanned code
    ref.read(scannerControllerProvider.notifier).onBarcodeScanned(code);
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerControllerProvider);

    // Listen for successful scan
    ref.listen<ScannerState>(scannerControllerProvider, (previous, next) {
      if (next.foundAsset != null && !next.isLoading) {
        // Save asset for result page
        ref.read(lastScannedAssetProvider.notifier).state = next.foundAsset;

        // Navigate to result page
        context.push(
          '${RoutePaths.scanner}/result',
          extra: {'code': next.scannedCode},
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scannerTitle),
        actions: [
          // Flash toggle
          IconButton(
            icon: Icon(
              scannerState.flashEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () {
              _scannerController?.toggleTorch();
              ref.read(scannerControllerProvider.notifier).toggleFlash();
            },
            tooltip: scannerState.flashEnabled
                ? AppStrings.disableFlash
                : AppStrings.enableFlash,
          ),
          // Camera switch
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _scannerController?.switchCamera(),
            tooltip: AppStrings.switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner view
          if (_isInitialized && scannerState.isScanning)
            MobileScanner(
              controller: _scannerController,
              onDetect: _onDetect,
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),

          // Scanner overlay
          const ScannerOverlay(),

          // Instructions
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scannerState.isLoading
                        ? AppStrings.scannerSearching
                        : AppStrings.scannerSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (scannerState.scannedCode != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Código: ${scannerState.scannedCode}',
                      style: const TextStyle(
                        color: AppTheme.primaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Loading indicator
          if (scannerState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    SizedBox(height: 16),
                    Text(
                      AppStrings.scannerSearching,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Error message
          if (scannerState.error != null)
            Positioned(
              bottom: 240,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        scannerState.error!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        ref
                            .read(scannerControllerProvider.notifier)
                            .resumeScanning();
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
