import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/env.dart';
import '../storage/secure_storage_service.dart';
import 'dio_interceptors.dart';

/// Provider for the Dio client instance.
final dioClientProvider = Provider<DioClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return DioClient(secureStorage: secureStorage);
});

/// Dio HTTP client wrapper with interceptors and configuration.
class DioClient {
  late final Dio _dio;
  final SecureStorageService secureStorage;

  DioClient({required this.secureStorage}) {
    _dio = Dio(_baseOptions);
    _setupInterceptors();
  }

  /// Base options for Dio.
  BaseOptions get _baseOptions => BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: Duration(seconds: Env.apiTimeout),
        receiveTimeout: Duration(seconds: Env.apiTimeout),
        sendTimeout: Duration(seconds: Env.apiTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

  /// Setup interceptors for logging, auth, and error handling.
  void _setupInterceptors() {
    // Auth interceptor - adds token to requests
    _dio.interceptors.add(AuthInterceptor(secureStorage: secureStorage));

    // Error interceptor - converts DioException to app exceptions
    _dio.interceptors.add(ErrorInterceptor());

    // Logging interceptor (only in debug mode)
    if (Env.debugMode) {
      _dio.interceptors.add(LoggingInterceptor());
    }
  }

  /// GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}
