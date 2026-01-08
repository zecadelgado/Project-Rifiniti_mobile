import 'env.dart';

/// API endpoints configuration.
/// All endpoints are relative to the base URL configured in environment.
abstract class Endpoints {
  /// Base URL from environment
  static String get baseUrl => Env.baseUrl;

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  /// POST /auth/login
  /// Body: { "email": string, "senha": string }
  /// Response: { "token": string, "user": User }
  static String get login => '/auth/login';

  /// POST /auth/logout
  /// Headers: Authorization: Bearer <token>
  static String get logout => '/auth/logout';

  /// GET /auth/me
  /// Headers: Authorization: Bearer <token>
  /// Response: User
  static String get me => '/auth/me';

  // ============================================================
  // ASSETS (PATRIMÔNIOS) ENDPOINTS
  // ============================================================

  /// GET /assets
  /// Query: ?limit=50&offset=0&search=string
  /// Response: { "data": Asset[], "total": int }
  static String get assets => '/assets';

  /// GET /assets/by-barcode/{code}
  /// Response: Asset
  static String assetByBarcode(String code) => '/assets/by-barcode/$code';

  /// GET /assets/{id}
  /// Response: Asset
  static String assetById(int id) => '/assets/$id';

  // ============================================================
  // MOVEMENTS (MOVIMENTAÇÕES) ENDPOINTS
  // ============================================================

  /// GET /movements
  /// Query: ?limit=50&offset=0&asset_id=int
  /// Response: { "data": Movement[], "total": int }
  static String get movements => '/movements';

  /// POST /movements
  /// Body: { "asset_id": int, "type": string, "destination_sector_id": int, ... }
  /// Response: Movement
  static String get createMovement => '/movements';

  /// GET /movements/{id}
  /// Response: Movement
  static String movementById(int id) => '/movements/$id';

  // ============================================================
  // SECTORS & LOCATIONS ENDPOINTS
  // ============================================================

  /// GET /sectors
  /// Response: Sector[]
  static String get sectors => '/sectors';

  /// GET /locations
  /// Query: ?sector_id=int
  /// Response: Location[]
  static String get locations => '/locations';

  // ============================================================
  // SYNC ENDPOINTS
  // ============================================================

  /// POST /sync/batch
  /// Body: { "operations": SyncOperation[] }
  /// Response: { "synced": int, "failed": int }
  static String get syncBatch => '/sync/batch';

  /// GET /sync/status
  /// Response: { "last_sync": datetime, "pending": int }
  static String get syncStatus => '/sync/status';
}
