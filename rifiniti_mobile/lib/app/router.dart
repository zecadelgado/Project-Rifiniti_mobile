import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/assets/presentation/pages/asset_details_page.dart';
import '../features/assets/presentation/pages/assets_list_page.dart';
import '../features/movements/presentation/pages/create_movement_page.dart';
import '../features/movements/presentation/pages/movements_list_page.dart';
import '../features/scanner/presentation/pages/scan_result_page.dart';
import '../features/scanner/presentation/pages/scanner_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import 'home_shell.dart';

/// Route paths constants
abstract class RoutePaths {
  static const splash = '/';
  static const login = '/login';
  static const home = '/home';
  static const scanner = '/home/scanner';
  static const scanResult = '/home/scanner/result';
  static const assets = '/home/assets';
  static const assetDetails = '/home/assets/details';
  static const movements = '/home/movements';
  static const createMovement = '/home/movements/create';
  static const settings = '/home/settings';
}

/// Provider for the GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == RoutePaths.login;
      final isSplash = state.matchedLocation == RoutePaths.splash;

      // Allow splash to handle initial routing
      if (isSplash) return null;

      // Redirect to login if not authenticated
      if (!isLoggedIn && !isLoggingIn) {
        return RoutePaths.login;
      }

      // Redirect to home if authenticated and trying to access login
      if (isLoggedIn && isLoggingIn) {
        return RoutePaths.scanner;
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: RoutePaths.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Login
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginPage(),
      ),

      // Home Shell with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          // Scanner Tab
          GoRoute(
            path: RoutePaths.scanner,
            builder: (context, state) => const ScannerPage(),
            routes: [
              GoRoute(
                path: 'result',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return ScanResultPage(
                    scannedCode: extra?['code'] as String? ?? '',
                  );
                },
              ),
            ],
          ),

          // Assets Tab
          GoRoute(
            path: RoutePaths.assets,
            builder: (context, state) => const AssetsListPage(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return AssetDetailsPage(
                    assetId: extra?['assetId'] as int?,
                    assetCode: extra?['assetCode'] as String?,
                  );
                },
              ),
            ],
          ),

          // Movements Tab
          GoRoute(
            path: RoutePaths.movements,
            builder: (context, state) => const MovementsListPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return CreateMovementPage(
                    assetId: extra?['assetId'] as int?,
                    assetCode: extra?['assetCode'] as String?,
                  );
                },
              ),
            ],
          ),

          // Settings Tab
          GoRoute(
            path: RoutePaths.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Página não encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.matchedLocation),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutePaths.scanner),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    ),
  );
});
