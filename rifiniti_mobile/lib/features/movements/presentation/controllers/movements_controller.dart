import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/movements_remote_datasource.dart';
import '../../data/repositories/movements_repository_impl.dart';
import '../../domain/entities/movement.dart';
import '../../domain/repositories/movements_repository.dart';
import '../../domain/usecases/create_movement_usecase.dart';
import '../../domain/usecases/list_movements_usecase.dart';

/// Movements list state.
class MovementsState {
  final bool isLoading;
  final List<Movement> movements;
  final String? error;

  const MovementsState({
    this.isLoading = false,
    this.movements = const [],
    this.error,
  });

  MovementsState copyWith({
    bool? isLoading,
    List<Movement>? movements,
    String? error,
  }) {
    return MovementsState(
      isLoading: isLoading ?? this.isLoading,
      movements: movements ?? this.movements,
      error: error,
    );
  }
}

/// Create movement state.
class CreateMovementState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final Movement? createdMovement;

  const CreateMovementState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.createdMovement,
  });

  CreateMovementState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    Movement? createdMovement,
  }) {
    return CreateMovementState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
      createdMovement: createdMovement,
    );
  }
}

/// Provider for MovementsRepository.
final movementsRepositoryProvider = Provider<MovementsRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return MovementsRepositoryImpl(
    remoteDataSource: MovementsRemoteDataSourceImpl(dioClient),
  );
});

/// Provider for ListMovementsUseCase.
final listMovementsUseCaseProvider = Provider<ListMovementsUseCase>((ref) {
  final repository = ref.watch(movementsRepositoryProvider);
  return ListMovementsUseCase(repository);
});

/// Provider for CreateMovementUseCase.
final createMovementUseCaseProvider = Provider<CreateMovementUseCase>((ref) {
  final repository = ref.watch(movementsRepositoryProvider);
  return CreateMovementUseCase(repository);
});

/// Provider for MovementsController.
final movementsControllerProvider =
    StateNotifierProvider<MovementsController, MovementsState>((ref) {
  final listUseCase = ref.watch(listMovementsUseCaseProvider);
  return MovementsController(listMovementsUseCase: listUseCase);
});

/// Movements controller using Riverpod StateNotifier.
class MovementsController extends StateNotifier<MovementsState> {
  final ListMovementsUseCase _listMovementsUseCase;

  MovementsController({
    required ListMovementsUseCase listMovementsUseCase,
  })  : _listMovementsUseCase = listMovementsUseCase,
        super(const MovementsState());

  /// Load movements list.
  Future<void> loadMovements({int? assetId}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _listMovementsUseCase(
      limit: 50,
      assetId: assetId,
    );

    result.fold(
      onSuccess: (movements) {
        state = state.copyWith(
          isLoading: false,
          movements: movements,
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

  /// Refresh movements list.
  Future<void> refresh({int? assetId}) async {
    await loadMovements(assetId: assetId);
  }
}

/// Provider for CreateMovementController.
final createMovementControllerProvider =
    StateNotifierProvider<CreateMovementController, CreateMovementState>((ref) {
  final createUseCase = ref.watch(createMovementUseCaseProvider);
  return CreateMovementController(createMovementUseCase: createUseCase);
});

/// Create movement controller.
class CreateMovementController extends StateNotifier<CreateMovementState> {
  final CreateMovementUseCase _createMovementUseCase;

  CreateMovementController({
    required CreateMovementUseCase createMovementUseCase,
  })  : _createMovementUseCase = createMovementUseCase,
        super(const CreateMovementState());

  /// Create a new movement.
  Future<bool> createMovement({
    required int assetId,
    required MovementType type,
    required DateTime date,
    int? destinationSectorId,
    int? destinationLocationId,
    String? responsible,
    String? reason,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    final result = await _createMovementUseCase(
      assetId: assetId,
      type: type,
      date: date,
      destinationSectorId: destinationSectorId,
      destinationLocationId: destinationLocationId,
      responsible: responsible,
      reason: reason,
      notes: notes,
    );

    return result.fold(
      onSuccess: (movement) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          createdMovement: movement,
        );
        return true;
      },
      onFailure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
    );
  }

  /// Reset state.
  void reset() {
    state = const CreateMovementState();
  }
}
