import 'package:dio/dio.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mens/features/auth/data/auth_repository_impl.dart';

// Create a provider for secure storage
final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

// Create the single Dio instance for the app
final _dio = Dio(
  BaseOptions(
    baseUrl: 'https://mens-shop-api-fhgf2.ondigitalocean.app/api',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ),
);

// Create a provider for Dio that configures and returns the instance with interceptors
final apiServiceProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  final prefs = ref.watch(sharedPreferencesProvider); // For clearing user cache

  // Clear existing interceptors to prevent duplicates during hot reloads
  _dio.interceptors.clear();

  // Add a LogInterceptor for debugging network requests in development
  _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  // Add our custom AuthInterceptor to handle tokens and 401 errors
  _dio.interceptors.add(AuthInterceptor(storage, prefs, ref));

  return _dio;
});

/// A custom Dio Interceptor to automatically handle authentication.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs; // For clearing cached user data on logout
  final Ref _ref; // Riverpod Ref to access notifiers

  AuthInterceptor(this._storage, this._prefs, this._ref);

  /// This method is called for every request before it is sent.
  /// It adds the JWT token to the 'Authorization' header.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Read the token from secure storage.
    final token = await _storage.read(key: 'jwt_token');

    // If a token exists, add it to the request header.
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue with the request.
    handler.next(options);
  }

  /// This method is called when a request results in an error.
  /// It specifically checks for 401 Unauthorized errors to handle session expiry.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if the error is a 401 Unauthorized response.
    if (err.response?.statusCode == 401) {
      print("AuthInterceptor: Detected 401 Unauthorized. Logging out user.");
      try {
        // 1. Manually clear the JWT token from secure storage.
        await _storage.delete(key: 'jwt_token');

        // 2. Clear the cached user profile data from shared preferences.
        await _prefs.remove('user_profile_cache'); // Ensure this key matches your repository key

        // 3. Update the AuthNotifier's state to logged out (null).
        //    This change will be picked up by the GoRouter's redirect logic,
        //    automatically navigating the user to the sign-in screen.
        //    We use Future.microtask to ensure this state update happens safely
        //    after the current build/event cycle.
        Future.microtask(() {
          _ref.read(authNotifierProvider.notifier).setLoggedOut();
        });

      } catch (e) {
        print("AuthInterceptor: Error during automatic logout process: $e");
      }

      // We still pass the error along so the original UI that made the request
      // can stop its loading indicator and handle the error if needed.
      return handler.next(err);
    }

    // If the error is not a 401, just pass it along without any special handling.
    return handler.next(err);
  }
}