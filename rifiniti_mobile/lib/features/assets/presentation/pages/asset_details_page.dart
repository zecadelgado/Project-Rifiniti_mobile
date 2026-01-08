import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../controllers/assets_controller.dart';

/// Asset details page.
class AssetDetailsPage extends ConsumerWidget {
  final int? assetId;
  final String? assetCode;

  const AssetDetailsPage({
    super.key,
    this.assetId,
    this.assetCode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implement proper asset loading by ID
    // For now, using the assets list to find the asset
    final assetsState = ref.watch(assetsControllerProvider);
    final asset = assetsState.assets.where((a) {
      if (assetId != null) return a.id == assetId;
      if (assetCode != null) return a.code == assetCode;
      return false;
    }).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.assetDetailsTitle),
      ),
      body: asset == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
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
                                  size: 18,
                                  color: AppTheme.getStatusColor(asset.status),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  Formatters.formatStatus(asset.status),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.getStatusColor(asset.status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Asset name
                          Text(
                            asset.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          if (asset.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              asset.description!,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Details card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informações',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _DetailRow(
                            label: AppStrings.assetCode,
                            value: asset.code,
                          ),
                          if (asset.serialNumber != null)
                            _DetailRow(
                              label: AppStrings.assetSerialNumber,
                              value: asset.serialNumber!,
                            ),
                          if (asset.category != null)
                            _DetailRow(
                              label: AppStrings.assetCategory,
                              value: asset.category!,
                            ),
                          if (asset.quantity != null)
                            _DetailRow(
                              label: AppStrings.assetQuantity,
                              value: asset.quantity.toString(),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Localização',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          if (asset.sectorName != null)
                            _DetailRow(
                              label: AppStrings.assetSector,
                              value: asset.sectorName!,
                            ),
                          if (asset.locationName != null)
                            _DetailRow(
                              label: AppStrings.assetLocation,
                              value: asset.locationName!,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Financial card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informações Financeiras',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          if (asset.acquisitionDate != null)
                            _DetailRow(
                              label: AppStrings.assetAcquisitionDate,
                              value: Formatters.formatDate(asset.acquisitionDate),
                            ),
                          if (asset.purchaseValue != null)
                            _DetailRow(
                              label: AppStrings.assetPurchaseValue,
                              value: Formatters.formatCurrency(asset.purchaseValue),
                            ),
                          if (asset.currentValue != null)
                            _DetailRow(
                              label: AppStrings.assetCurrentValue,
                              value: Formatters.formatCurrency(asset.currentValue),
                            ),
                          if (asset.supplierName != null)
                            _DetailRow(
                              label: AppStrings.assetSupplier,
                              value: asset.supplierName!,
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action button
                  ElevatedButton.icon(
                    onPressed: () {
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

                  const SizedBox(height: 16),

                  // TODO: Add more actions like view history, attachments, etc.
                  Center(
                    child: Text(
                      '// TODO: Adicionar histórico de movimentações, anexos, etc.',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Detail row widget.
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
