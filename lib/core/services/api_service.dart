import 'package:dio/dio.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mens/features/auth/data/auth_repository_impl.dart';
// We remove the global loading provider, as we'll handle loading locally.
// import 'package:mens/shared/providers/loading_provider.dart';

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
  // (Don't ship with this enabled in release builds)
  _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

  // NOTE: We have *removed* the LoadingInterceptor.
  // This is intentional. We will handle loading state inside our
  // AwesomeDialogHelper, called from the UI. This prevents
  // a global spinner from conflicting with our modal dialogs.

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

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // This is perfect. A 401 is a global event (session expired)
    // and should be handled globally (log out).
    if (err.response?.statusCode == 401) {
      try {
        await _storage.delete(key: 'jwt_token');
        await _prefs.remove('user_profile_cache');
        Future.microtask(() {
          _ref.read(authNotifierProvider.notifier).setLoggedOut();
        });
      } catch (e) {
        // Error during automatic logout
      }
      return handler.next(err);
    }
    // For all other errors (404, 500, 422, etc.), we let them
    // propagate to the notifier so the UI can handle them locally.
    return handler.next(err);
  }
}