import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create a provider for secure storage
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// Create the Dio instance
final _dio = Dio(
  BaseOptions(
    baseUrl: 'https://mens-shop-api-fhgf2.ondigitalocean.app/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ),
);

// Create a provider for Dio, adding the interceptor
final apiServiceProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);

  // Add interceptors
  _dio.interceptors
      .clear(); // Clear existing to prevent duplicates on hot reload
  _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  _dio.interceptors.add(AuthInterceptor(storage)); // Add our custom interceptor

  return _dio;
});

// Custom interceptor to add the auth token
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read the token from storage
    final token = await _storage.read(key: 'jwt_token');

    // If token exists, add it to the Authorization header
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue with the request
    handler.next(options);
  }
}
