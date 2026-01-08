import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration singleton.
/// Provides access to environment variables loaded from .env file.
class Env {
  Env._();

  /// Base URL for the Rifiniti Desk API.
  /// Returns empty string if not configured (mock mode).
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';

  /// Current environment (DEV, STAGING, PROD).
  static String get appEnv => dotenv.env['APP_ENV'] ?? 'DEV';

  /// API timeout in seconds.
  static int get apiTimeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30') ?? 30;

  /// Whether debug mode is enabled.
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';

  /// Whether the app is running in development mode.
  static bool get isDev => appEnv == 'DEV';

  /// Whether the app is running in production mode.
  static bool get isProd => appEnv == 'PROD';

  /// Whether API is configured (not in mock mode).
  static bool get isApiConfigured => baseUrl.isNotEmpty;
}
