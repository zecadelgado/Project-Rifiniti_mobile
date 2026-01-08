import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../network/dio_client.dart';
import 'hive_service.dart';

/// Provider for SyncQueueService.
final syncQueueProvider = Provider<SyncQueueService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SyncQueueService(dioClient: dioClient);
});

/// Sync operation types.
enum SyncOperationType {
  createMovement,
  updateAsset,
  // TODO: Add more operation types as needed
}

/// Represents a sync operation to be queued.
class SyncOperation {
  final SyncOperationType type;
  final String endpoint;
  final String method; // POST, PUT, PATCH, DELETE
  final Map<String, dynamic> data;
  final DateTime createdAt;

  SyncOperation({
    required this.type,
    required this.endpoint,
    required this.method,
    required this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'endpoint': endpoint,
        'method': method,
        'data': data,
        'created_at': createdAt.toIso8601String(),
      };

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SyncOperationType.createMovement,
      ),
      endpoint: json['endpoint'] as String,
      method: json['method'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Service for managing offline sync queue.
/// Queues operations when offline and syncs when connectivity is restored.
class SyncQueueService {
  final DioClient dioClient;
  final HiveService _hiveService = HiveService.instance;
  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncQueueService({required this.dioClient});

  /// Start listening for connectivity changes.
  void startListening() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
    print('[SyncQueue] Started listening for connectivity changes');
  }

  /// Stop listening for connectivity changes.
  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    print('[SyncQueue] Stopped listening for connectivity changes');
  }

  /// Handle connectivity changes.
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final hasConnection = results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);

    if (hasConnection) {
      print('[SyncQueue] Connectivity restored, attempting sync...');
      await syncPendingOperations();
    }
  }

  /// Check if device is online.
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  /// Queue an operation for later sync.
  Future<String> queueOperation(SyncOperation operation) async {
    final id = await _hiveService.addToSyncQueue(operation.toJson());
    print('[SyncQueue] Queued operation: ${operation.type.name} (id: $id)');
    return id;
  }

  /// Get count of pending operations.
  int getPendingCount() {
    return _hiveService.getSyncQueueCount();
  }

  /// Get all pending operations.
  List<Map<String, dynamic>> getPendingOperations() {
    return _hiveService.getPendingSyncOperations();
  }

  /// Sync all pending operations.
  Future<SyncResult> syncPendingOperations() async {
    if (_isSyncing) {
      print('[SyncQueue] Sync already in progress');
      return SyncResult(synced: 0, failed: 0, pending: getPendingCount());
    }

    if (!Env.isApiConfigured) {
      print('[SyncQueue] API not configured, skipping sync');
      return SyncResult(synced: 0, failed: 0, pending: getPendingCount());
    }

    final online = await isOnline();
    if (!online) {
      print('[SyncQueue] Device is offline, skipping sync');
      return SyncResult(synced: 0, failed: 0, pending: getPendingCount());
    }

    _isSyncing = true;
    var synced = 0;
    var failed = 0;

    try {
      final pendingOps = _hiveService.getPendingSyncOperations();
      print('[SyncQueue] Syncing ${pendingOps.length} operations...');

      for (final opData in pendingOps) {
        final id = opData['id'] as String;
        final operation = SyncOperation.fromJson(
          Map<String, dynamic>.from(opData['operation'] as Map),
        );

        try {
          await _executeOperation(operation);
          await _hiveService.markAsSynced(id);
          synced++;
          print('[SyncQueue] Synced operation: $id');
        } catch (e) {
          await _hiveService.incrementAttempt(id);
          failed++;
          print('[SyncQueue] Failed to sync operation $id: $e');
        }
      }

      // Clean up synced operations
      await _hiveService.clearSyncedOperations();

      // Update last sync time
      await _hiveService.saveLastSyncTime(DateTime.now());

      print('[SyncQueue] Sync complete: $synced synced, $failed failed');
    } finally {
      _isSyncing = false;
    }

    return SyncResult(
      synced: synced,
      failed: failed,
      pending: getPendingCount(),
    );
  }

  /// Execute a single sync operation.
  Future<void> _executeOperation(SyncOperation operation) async {
    // TODO: Implement actual API calls when backend is ready
    // For now, just log and simulate success

    print('[SyncQueue] Executing: ${operation.method} ${operation.endpoint}');
    print('[SyncQueue] Data: ${operation.data}');

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // In production, this would be:
    // switch (operation.method) {
    //   case 'POST':
    //     await dioClient.post(operation.endpoint, data: operation.data);
    //     break;
    //   case 'PUT':
    //     await dioClient.put(operation.endpoint, data: operation.data);
    //     break;
    //   case 'PATCH':
    //     await dioClient.patch(operation.endpoint, data: operation.data);
    //     break;
    //   case 'DELETE':
    //     await dioClient.delete(operation.endpoint, data: operation.data);
    //     break;
    // }
  }
}

/// Result of a sync operation.
class SyncResult {
  final int synced;
  final int failed;
  final int pending;

  const SyncResult({
    required this.synced,
    required this.failed,
    required this.pending,
  });

  @override
  String toString() =>
      'SyncResult(synced: $synced, failed: $failed, pending: $pending)';
}
