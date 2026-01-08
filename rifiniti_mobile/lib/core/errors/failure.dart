import 'package:dio/dio.dart';

import 'app_exception.dart';

/// Represents a failure in the application.
/// Used to convert exceptions to user-friendly error messages.
sealed class Failure {
  final String message;
  final String? code;

  const Failure({required this.message, this.code});

  @override
  String toString() => 'Failure: $message';
}

/// Server failure (5xx errors).
class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

/// Network failure (no connection).
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

/// Authentication failure.
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

/// Validation failure.
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code,
    this.fieldErrors,
  });
}

/// Not found failure.
class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

/// Cache failure.
class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

/// Unknown failure.
class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}

/// Extension to convert DioException to Failure.
extension DioExceptionToFailure on DioException {
  Failure toFailure() {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Tempo de conexão esgotado. Tente novamente.',
          code: 'TIMEOUT',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Erro de conexão. Verifique sua internet.',
          code: 'CONNECTION_ERROR',
        );

      case DioExceptionType.badResponse:
        final statusCode = response?.statusCode;
        final data = response?.data;
        final serverMessage = data is Map ? data['message'] as String? : null;

        if (statusCode == 401) {
          return AuthFailure(
            message: serverMessage ?? 'Não autorizado. Faça login novamente.',
            code: 'UNAUTHORIZED',
          );
        }

        if (statusCode == 403) {
          return AuthFailure(
            message: serverMessage ?? 'Acesso negado.',
            code: 'FORBIDDEN',
          );
        }

        if (statusCode == 404) {
          return NotFoundFailure(
            message: serverMessage ?? 'Recurso não encontrado.',
            code: 'NOT_FOUND',
          );
        }

        if (statusCode == 422) {
          final errors = data is Map ? data['errors'] as Map<String, dynamic>? : null;
          return ValidationFailure(
            message: serverMessage ?? 'Dados inválidos.',
            code: 'VALIDATION_ERROR',
            fieldErrors: errors?.map(
              (key, value) => MapEntry(key, List<String>.from(value as List)),
            ),
          );
        }

        if (statusCode != null && statusCode >= 500) {
          return ServerFailure(
            message: serverMessage ?? 'Erro no servidor. Tente mais tarde.',
            code: 'SERVER_ERROR',
          );
        }

        return UnknownFailure(
          message: serverMessage ?? 'Ocorreu um erro. Tente novamente.',
          code: 'UNKNOWN',
        );

      case DioExceptionType.cancel:
        return const UnknownFailure(
          message: 'Requisição cancelada.',
          code: 'CANCELLED',
        );

      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Certificado inválido.',
          code: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.unknown:
        return UnknownFailure(
          message: message ?? 'Ocorreu um erro desconhecido.',
          code: 'UNKNOWN',
        );
    }
  }
}

/// Extension to convert AppException to Failure.
extension AppExceptionToFailure on AppException {
  Failure toFailure() {
    return switch (this) {
      NetworkException() => NetworkFailure(message: message, code: code),
      ServerException() => ServerFailure(message: message, code: code),
      AuthException() => AuthFailure(message: message, code: code),
      ValidationException(fieldErrors: final errors) => ValidationFailure(
          message: message,
          code: code,
          fieldErrors: errors,
        ),
      CacheException() => CacheFailure(message: message, code: code),
      _ => UnknownFailure(message: message, code: code),
    };
  }
}
