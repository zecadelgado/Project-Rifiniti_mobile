/// Authentication token entity.
class AuthToken {
  final String token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final User user;

  const AuthToken({
    required this.token,
    this.refreshToken,
    this.expiresAt,
    required this.user,
  });

  /// Check if token is expired.
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if token is valid.
  bool get isValid => token.isNotEmpty && !isExpired;

  @override
  String toString() => 'AuthToken(user: ${user.email}, expires: $expiresAt)';
}

/// User entity.
class User {
  final int id;
  final String email;
  final String name;
  final String? role;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.role,
  });

  /// Check if user is admin.
  bool get isAdmin => role == 'admin' || role == 'master';

  /// Check if user is master.
  bool get isMaster => role == 'master';

  @override
  String toString() => 'User(id: $id, email: $email, name: $name, role: $role)';
}
