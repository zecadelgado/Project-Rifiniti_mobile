import '../../../../core/errors/result.dart';
import '../entities/auth_token.dart';

/// Authentication repository interface.
/// Defines the contract for authentication operations.
abstract class AuthRepository {
  /// Login with email and password.
  /// Returns [AuthToken] on success or [Failure] on error.
  Future<Result<AuthToken>> login({
    required String email,
    required String password,
  });

  /// Logout the current user.
  /// Returns true on success or [Failure] on error.
  Future<Result<bool>> logout();

  /// Get current authenticated user.
  /// Returns [User] on success or [Failure] on error.
  Future<Result<User>> getCurrentUser();

  /// Check if user is authenticated.
  Future<bool> isAuthenticated();

  /// Get stored token.
  Future<String?> getToken();

  /// Clear authentication data.
  Future<void> clearAuth();
}
