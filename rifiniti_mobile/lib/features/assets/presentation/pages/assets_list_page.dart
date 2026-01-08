import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/asset.dart';
import '../controllers/assets_controller.dart';

/// Assets list page showing all assets.
class AssetsListPage extends ConsumerStatefulWidget {
  const AssetsListPage({super.key});

  @override
  ConsumerState<AssetsListPage> createState() => _AssetsListPageState();
}

class _AssetsListPageState extends ConsumerState<AssetsListPage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load assets on init
    Future.microtask(() {
      ref.read(assetsControllerProvider.notifier).loadAssets();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(assetsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.assetsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchAssets,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(assetsControllerProvider.notifier)
                              .search('');
                        },
                      )
                    : null,
              ),
              onSubmitted: (value) {
                ref.read(assetsControllerProvider.notifier).search(value);
              },
            ),
          ),

          // Filter chips
          if (state.selectedCategory != null || state.selectedStatus != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  if (state.selectedCategory != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(state.selectedCategory!),
                        onDeleted: () {
                          ref
                              .read(assetsControllerProvider.notifier)
                              .filterByCategory(null);
                        },
                      ),
                    ),
                  if (state.selectedStatus != null)
                    Chip(
                      label: Text(Formatters.formatStatus(state.selectedStatus)),
                      onDeleted: () {
                        ref
                            .read(assetsControllerProvider.notifier)
                            .filterByStatus(null);
                      },
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      ref.read(assetsControllerProvider.notifier).clearFilters();
                    },
                    child: const Text(AppStrings.clear),
                  ),
                ],
              ),
            ),

          // Assets list
          Expanded(
            child: _buildAssetsList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetsList(AssetsState state) {
    if (state.isLoading && state.assets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(assetsControllerProvider.notifier).loadAssets();
              },
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
    }

    if (state.assets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppStrings.noData,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(assetsControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.assets.length,
        itemBuilder: (context, index) {
          final asset = state.assets[index];
          return _AssetCard(asset: asset);
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(),
    );
  }
}

/// Asset card widget.
class _AssetCard extends StatelessWidget {
  final Asset asset;

  const _AssetCard({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push(
            '${RoutePaths.assets}/details',
            extra: {'assetId': asset.id, 'assetCode': asset.code},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Status indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.getStatusColor(asset.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  AppTheme.getStatusIcon(asset.status),
                  color: AppTheme.getStatusColor(asset.status),
                ),
              ),
              const SizedBox(width: 16),

              // Asset info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset.code,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            asset.fullLocation,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filter bottom sheet.
class _FilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.filter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Category filter
          const Text(
            AppStrings.assetCategory,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Eletrônico',
                value: 'Eletronico',
                type: 'category',
              ),
              _FilterChip(
                label: 'Móvel',
                value: 'Movel',
                type: 'category',
              ),
              _FilterChip(
                label: 'Imobilizado',
                value: 'Imobilizado',
                type: 'category',
              ),
              _FilterChip(
                label: 'Utilitários',
                value: 'Utilitarios',
                type: 'category',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Status filter
          const Text(
            AppStrings.assetStatus,
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Ativo',
                value: 'ativo',
                type: 'status',
              ),
              _FilterChip(
                label: 'Baixado',
                value: 'baixado',
                type: 'status',
              ),
              _FilterChip(
                label: 'Em Manutenção',
                value: 'em_manutencao',
                type: 'status',
              ),
              _FilterChip(
                label: 'Desaparecido',
                value: 'desaparecido',
                type: 'status',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aplicar'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filter chip widget.
class _FilterChip extends ConsumerWidget {
  final String label;
  final String value;
  final String type;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(assetsControllerProvider);
    final isSelected = type == 'category'
        ? state.selectedCategory == value
        : state.selectedStatus == value;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (type == 'category') {
          ref
              .read(assetsControllerProvider.notifier)
              .filterByCategory(selected ? value : null);
        } else {
          ref
              .read(assetsControllerProvider.notifier)
              .filterByStatus(selected ? value : null);
        }
      },
    );
  }
}
