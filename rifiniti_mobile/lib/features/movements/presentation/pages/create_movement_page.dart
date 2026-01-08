import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/movement.dart';
import '../controllers/movements_controller.dart';

/// Create movement page.
class CreateMovementPage extends ConsumerStatefulWidget {
  final int? assetId;
  final String? assetCode;

  const CreateMovementPage({
    super.key,
    this.assetId,
    this.assetCode,
  });

  @override
  ConsumerState<CreateMovementPage> createState() => _CreateMovementPageState();
}

class _CreateMovementPageState extends ConsumerState<CreateMovementPage> {
  final _formKey = GlobalKey<FormState>();
  final _responsibleController = TextEditingController();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  MovementType _selectedType = MovementType.transfer;
  DateTime _selectedDate = DateTime.now();
  int? _selectedSectorId;
  int? _selectedLocationId;

  @override
  void dispose() {
    _responsibleController.dispose();
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.assetId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nenhum ativo selecionado'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final success = await ref
        .read(createMovementControllerProvider.notifier)
        .createMovement(
          assetId: widget.assetId!,
          type: _selectedType,
          date: _selectedDate,
          destinationSectorId: _selectedSectorId,
          destinationLocationId: _selectedLocationId,
          responsible: _responsibleController.text.trim().isNotEmpty
              ? _responsibleController.text.trim()
              : null,
          reason: _reasonController.text.trim().isNotEmpty
              ? _reasonController.text.trim()
              : null,
          notes: _notesController.text.trim().isNotEmpty
              ? _notesController.text.trim()
              : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.movementCreated),
          backgroundColor: AppTheme.successColor,
        ),
      );

      // Refresh movements list
      ref.read(movementsControllerProvider.notifier).refresh();

      // Go back
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createMovementControllerProvider);

    // Listen for errors
    ref.listen<CreateMovementState>(createMovementControllerProvider,
        (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createMovementTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Asset info card
              if (widget.assetCode != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.inventory_2,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ativo selecionado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.assetCode!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Movement type
              const Text(
                AppStrings.movementType,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              SegmentedButton<MovementType>(
                segments: MovementType.values.map((type) {
                  return ButtonSegment<MovementType>(
                    value: type,
                    label: Text(type.displayName),
                  );
                }).toList(),
                selected: {_selectedType},
                onSelectionChanged: (selected) {
                  setState(() {
                    _selectedType = selected.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Date picker
              const Text(
                AppStrings.movementDate,
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Destination sector
              // TODO: Replace with actual sector dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: AppStrings.destinationSector,
                  prefixIcon: Icon(Icons.business),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('TI')),
                  DropdownMenuItem(value: 2, child: Text('Administrativo')),
                  DropdownMenuItem(value: 3, child: Text('RH')),
                  DropdownMenuItem(value: 4, child: Text('Financeiro')),
                  DropdownMenuItem(value: 5, child: Text('Manutenção')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSectorId = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Destination location
              // TODO: Replace with actual location dropdown based on sector
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: AppStrings.destinationLocation,
                  prefixIcon: Icon(Icons.location_on),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Sala 101')),
                  DropdownMenuItem(value: 2, child: Text('Sala 201')),
                  DropdownMenuItem(value: 3, child: Text('Sala 301')),
                  DropdownMenuItem(value: 4, child: Text('Recepção')),
                  DropdownMenuItem(value: 5, child: Text('Almoxarifado')),
                  DropdownMenuItem(value: 6, child: Text('Oficina')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLocationId = value;
                  });
                },
              ),

              const SizedBox(height: 24),

              // Responsible
              TextFormField(
                controller: _responsibleController,
                decoration: const InputDecoration(
                  labelText: AppStrings.responsible,
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 16),

              // Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: AppStrings.reason,
                  prefixIcon: Icon(Icons.info_outline),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: AppStrings.notes,
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : _handleSubmit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          AppStrings.save,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
