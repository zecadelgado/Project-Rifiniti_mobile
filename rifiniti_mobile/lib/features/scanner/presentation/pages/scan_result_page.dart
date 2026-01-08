import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../controllers/scanner_controller.dart';

/// Scan result page showing scanned asset details.
class ScanResultPage extends ConsumerWidget {
  final String scannedCode;

  const ScanResultPage({
    super.key,
    required this.scannedCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asset = ref.watch(lastScannedAssetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanResultTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(scannerControllerProvider.notifier).resumeScanning();
            context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Scanned code card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_2,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.scannedCode,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scannedCode,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Asset details card
            if (asset != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with status
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              asset.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.getStatusColor(asset.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  AppTheme.getStatusIcon(asset.status),
                                  size: 16,
                                  color: AppTheme.getStatusColor(asset.status),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  Formatters.formatStatus(asset.status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getStatusColor(asset.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (asset.description != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          asset.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],

                      const Divider(height: 24),

                      // Details grid
                      _buildDetailRow(
                        AppStrings.assetId,
                        asset.id.toString(),
                        Icons.tag,
                      ),
                      _buildDetailRow(
                        AppStrings.assetCode,
                        asset.code,
                        Icons.qr_code,
                      ),
                      if (asset.serialNumber != null)
                        _buildDetailRow(
                          AppStrings.assetSerialNumber,
                          asset.serialNumber!,
                          Icons.numbers,
                        ),
                      if (asset.category != null)
                        _buildDetailRow(
                          AppStrings.assetCategory,
                          asset.category!,
                          Icons.category,
                        ),
                      if (asset.sectorName != null)
                        _buildDetailRow(
                          AppStrings.assetSector,
                          asset.sectorName!,
                          Icons.business,
                        ),
                      if (asset.locationName != null)
                        _buildDetailRow(
                          AppStrings.assetLocation,
                          asset.locationName!,
                          Icons.location_on,
                        ),
                      if (asset.currentValue != null)
                        _buildDetailRow(
                          AppStrings.assetCurrentValue,
                          Formatters.formatCurrency(asset.currentValue),
                          Icons.attach_money,
                        ),
                      if (asset.acquisitionDate != null)
                        _buildDetailRow(
                          AppStrings.assetAcquisitionDate,
                          Formatters.formatDate(asset.acquisitionDate),
                          Icons.calendar_today,
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to create movement page
                  context.push(
                    '${RoutePaths.movements}/create',
                    extra: {
                      'assetId': asset.id,
                      'assetCode': asset.code,
                    },
                  );
                },
                icon: const Icon(Icons.swap_horiz),
                label: const Text(AppStrings.registerMovement),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to asset details page
                  context.push(
                    '${RoutePaths.assets}/details',
                    extra: {
                      'assetId': asset.id,
                      'assetCode': asset.code,
                    },
                  );
                },
                icon: const Icon(Icons.info_outline),
                label: const Text(AppStrings.openDetails),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ] else ...[
              // No asset found
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.scannerNotFound,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Scan again button
            TextButton.icon(
              onPressed: () {
                ref.read(scannerControllerProvider.notifier).resumeScanning();
                context.pop();
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text(AppStrings.scanAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[500],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
