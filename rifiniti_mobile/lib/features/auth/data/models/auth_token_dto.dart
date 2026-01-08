import '../../domain/entities/auth_token.dart';

/// Data Transfer Object for authentication response.
class AuthTokenDto {
  final String token;
  final String? refreshToken;
  final String? expiresAt;
  final UserDto user;

  const AuthTokenDto({
    required this.token,
    this.refreshToken,
    this.expiresAt,
    required this.user,
  });

  /// Create from JSON map.
  factory AuthTokenDto.fromJson(Map<String, dynamic> json) {
    return AuthTokenDto(
      token: json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String?,
      expiresAt: json['expires_at'] as String?,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() => {
        'token': token,
        'refresh_token': refreshToken,
        'expires_at': expiresAt,
        'user': user.toJson(),
      };

  /// Convert to domain entity.
  AuthToken toEntity() => AuthToken(
        token: token,
        refreshToken: refreshToken,
        expiresAt: expiresAt != null ? DateTime.tryParse(expiresAt!) : null,
        user: user.toEntity(),
      );
}

/// Data Transfer Object for user data.
class UserDto {
  final int id;
  final String email;
  final String name;
  final String? role;

  const UserDto({
    required this.id,
    required this.email,
    required this.name,
    this.role,
  });

  /// Create from JSON map.
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int? ?? json['id_usuario'] as int? ?? 0,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? json['nome'] as String? ?? '',
      role: json['role'] as String? ?? json['tipo'] as String?,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role,
      };

  /// Convert to domain entity.
  User toEntity() => User(
        id: id,
        email: email,
        name: name,
        role: role,
      );
}
