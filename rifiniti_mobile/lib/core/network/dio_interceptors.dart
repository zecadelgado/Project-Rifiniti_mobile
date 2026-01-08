import 'package:dio/dio.dart';

import '../storage/secure_storage_service.dart';

/// Interceptor for adding authentication token to requests.
class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorage;

  AuthInterceptor({required this.secureStorage});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await secureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh or logout
      print('[AuthInterceptor] Token expired or invalid');
    }

    handler.next(err);
  }
}

/// Interceptor for error handling and transformation.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log error details
    print('[ErrorInterceptor] ${err.type}: ${err.message}');
    print('[ErrorInterceptor] URL: ${err.requestOptions.uri}');

    if (err.response != null) {
      print('[ErrorInterceptor] Status: ${err.response?.statusCode}');
      print('[ErrorInterceptor] Data: ${err.response?.data}');
    }

    handler.next(err);
  }
}

/// Interceptor for logging requests and responses.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('');
    print('┌─────────────────────────────────────────────────────────────');
    print('│ REQUEST');
    print('├─────────────────────────────────────────────────────────────');
    print('│ ${options.method} ${options.uri}');
    print('│ Headers: ${options.headers}');
    if (options.data != null) {
      print('│ Body: ${options.data}');
    }
    print('└─────────────────────────────────────────────────────────────');
    print('');

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('');
    print('┌─────────────────────────────────────────────────────────────');
    print('│ RESPONSE');
    print('├─────────────────────────────────────────────────────────────');
    print('│ ${response.statusCode} ${response.requestOptions.uri}');
    print('│ Data: ${response.data}');
    print('└─────────────────────────────────────────────────────────────');
    print('');

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('');
    print('┌─────────────────────────────────────────────────────────────');
    print('│ ERROR');
    print('├─────────────────────────────────────────────────────────────');
    print('│ ${err.type}');
    print('│ ${err.requestOptions.uri}');
    print('│ Message: ${err.message}');
    if (err.response != null) {
      print('│ Status: ${err.response?.statusCode}');
      print('│ Data: ${err.response?.data}');
    }
    print('└─────────────────────────────────────────────────────────────');
    print('');

    handler.next(err);
  }
}

/// Interceptor for retry logic on network errors.
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only retry on connection errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

      if (retryCount < maxRetries) {
        print('[RetryInterceptor] Retrying request (${retryCount + 1}/$maxRetries)');

        err.requestOptions.extra['retryCount'] = retryCount + 1;

        // Wait before retrying
        await Future.delayed(Duration(seconds: retryCount + 1));

        try {
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to next handler if retry fails
        }
      }
    }

    handler.next(err);
  }
}
