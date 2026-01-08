import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/movement.dart';
import '../controllers/movements_controller.dart';

/// Movements list page.
class MovementsListPage extends ConsumerStatefulWidget {
  const MovementsListPage({super.key});

  @override
  ConsumerState<MovementsListPage> createState() => _MovementsListPageState();
}

class _MovementsListPageState extends ConsumerState<MovementsListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(movementsControllerProvider.notifier).loadMovements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(movementsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.movementsTitle),
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('${RoutePaths.movements}/create');
        },
        icon: const Icon(Icons.add),
        label: const Text('Nova'),
      ),
    );
  }

  Widget _buildBody(MovementsState state) {
    if (state.isLoading && state.movements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.movements.isEmpty) {
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
                ref.read(movementsControllerProvider.notifier).loadMovements();
              },
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      );
    }

    if (state.movements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swap_horiz, size: 64, color: Colors.grey[400]),
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
      onRefresh: () => ref.read(movementsControllerProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.movements.length,
        itemBuilder: (context, index) {
          final movement = state.movements[index];
          return _MovementCard(movement: movement);
        },
      ),
    );
  }
}

/// Movement card widget.
class _MovementCard extends StatelessWidget {
  final Movement movement;

  const _MovementCard({required this.movement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(movement.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    movement.type.displayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(movement.type),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.formatDate(movement.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Asset info
            if (movement.assetName != null) ...[
              Text(
                movement.assetName!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
            ],

            if (movement.assetCode != null)
              Text(
                'Código: ${movement.assetCode}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),

            const Divider(height: 24),

            // Movement details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Origem',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movement.originLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: AppTheme.primaryColor,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Destino',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        movement.destinationLocation,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (movement.responsible != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    movement.responsible!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(MovementType type) {
    switch (type) {
      case MovementType.transfer:
        return AppTheme.primaryColor;
      case MovementType.loan:
        return Colors.orange;
      case MovementType.returnItem:
        return Colors.green;
      case MovementType.maintenance:
        return Colors.purple;
    }
  }
}
