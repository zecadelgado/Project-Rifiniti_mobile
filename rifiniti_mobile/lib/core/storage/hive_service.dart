import 'package:hive_flutter/hive_flutter.dart';

/// Service for Hive local storage operations.
/// Manages boxes for caching assets, movements, and sync queue.
class HiveService {
  static final HiveService _instance = HiveService._internal();
  static HiveService get instance => _instance;

  HiveService._internal();

  // Box names
  static const String _assetsBoxName = 'assets_cache';
  static const String _movementsBoxName = 'movements_cache';
  static const String _syncQueueBoxName = 'sync_queue';
  static const String _settingsBoxName = 'settings';
  static const String _lastScannedBoxName = 'last_scanned';

  // Boxes
  late Box<Map> _assetsBox;
  late Box<Map> _movementsBox;
  late Box<Map> _syncQueueBox;
  late Box<dynamic> _settingsBox;
  late Box<Map> _lastScannedBox;

  /// Initialize Hive and open boxes.
  Future<void> init() async {
    _assetsBox = await Hive.openBox<Map>(_assetsBoxName);
    _movementsBox = await Hive.openBox<Map>(_movementsBoxName);
    _syncQueueBox = await Hive.openBox<Map>(_syncQueueBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
    _lastScannedBox = await Hive.openBox<Map>(_lastScannedBoxName);

    print('[HiveService] Initialized with boxes: '
        '$_assetsBoxName, $_movementsBoxName, $_syncQueueBoxName, '
        '$_settingsBoxName, $_lastScannedBoxName');
  }

  // ============================================================
  // ASSETS CACHE
  // ============================================================

  /// Cache an asset by its code.
  Future<void> cacheAsset(String code, Map<String, dynamic> asset) async {
    await _assetsBox.put(code, asset);
  }

  /// Get cached asset by code.
  Map<String, dynamic>? getCachedAsset(String code) {
    final data = _assetsBox.get(code);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Get all cached assets.
  List<Map<String, dynamic>> getAllCachedAssets() {
    return _assetsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Clear assets cache.
  Future<void> clearAssetsCache() async {
    await _assetsBox.clear();
  }

  // ============================================================
  // MOVEMENTS CACHE
  // ============================================================

  /// Cache a movement.
  Future<void> cacheMovement(int id, Map<String, dynamic> movement) async {
    await _movementsBox.put(id.toString(), movement);
  }

  /// Cache multiple movements.
  Future<void> cacheMovements(List<Map<String, dynamic>> movements) async {
    final entries = <String, Map>{};
    for (final movement in movements) {
      final id = movement['id']?.toString();
      if (id != null) {
        entries[id] = movement;
      }
    }
    await _movementsBox.putAll(entries);
  }

  /// Get cached movement by ID.
  Map<String, dynamic>? getCachedMovement(int id) {
    final data = _movementsBox.get(id.toString());
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Get all cached movements.
  List<Map<String, dynamic>> getAllCachedMovements() {
    return _movementsBox.values
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Clear movements cache.
  Future<void> clearMovementsCache() async {
    await _movementsBox.clear();
  }

  // ============================================================
  // LAST SCANNED
  // ============================================================

  /// Save last scanned asset.
  Future<void> saveLastScanned(Map<String, dynamic> asset) async {
    await _lastScannedBox.put('last', asset);
  }

  /// Get last scanned asset.
  Map<String, dynamic>? getLastScanned() {
    final data = _lastScannedBox.get('last');
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  /// Save a setting.
  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  /// Get a setting.
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  /// Get last sync timestamp.
  DateTime? getLastSyncTime() {
    final timestamp = _settingsBox.get('last_sync_time');
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  /// Save last sync timestamp.
  Future<void> saveLastSyncTime(DateTime time) async {
    await _settingsBox.put('last_sync_time', time.millisecondsSinceEpoch);
  }

  // ============================================================
  // SYNC QUEUE
  // ============================================================

  /// Add operation to sync queue.
  Future<String> addToSyncQueue(Map<String, dynamic> operation) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final queueItem = {
      'id': id,
      'operation': operation,
      'created_at': DateTime.now().toIso8601String(),
      'synced': false,
      'attempts': 0,
    };
    await _syncQueueBox.put(id, queueItem);
    return id;
  }

  /// Get all pending sync operations.
  List<Map<String, dynamic>> getPendingSyncOperations() {
    return _syncQueueBox.values
        .where((item) => item['synced'] != true)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Mark operation as synced.
  Future<void> markAsSynced(String id) async {
    final item = _syncQueueBox.get(id);
    if (item != null) {
      item['synced'] = true;
      item['synced_at'] = DateTime.now().toIso8601String();
      await _syncQueueBox.put(id, item);
    }
  }

  /// Increment attempt count for an operation.
  Future<void> incrementAttempt(String id) async {
    final item = _syncQueueBox.get(id);
    if (item != null) {
      item['attempts'] = (item['attempts'] ?? 0) + 1;
      item['last_attempt'] = DateTime.now().toIso8601String();
      await _syncQueueBox.put(id, item);
    }
  }

  /// Remove synced operations from queue.
  Future<void> clearSyncedOperations() async {
    final keysToRemove = <dynamic>[];
    for (final entry in _syncQueueBox.toMap().entries) {
      if (entry.value['synced'] == true) {
        keysToRemove.add(entry.key);
      }
    }
    await _syncQueueBox.deleteAll(keysToRemove);
  }

  /// Get sync queue count.
  int getSyncQueueCount() {
    return getPendingSyncOperations().length;
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  /// Clear all cached data.
  Future<void> clearAll() async {
    await Future.wait([
      _assetsBox.clear(),
      _movementsBox.clear(),
      _syncQueueBox.clear(),
      _settingsBox.clear(),
      _lastScannedBox.clear(),
    ]);
  }
}
