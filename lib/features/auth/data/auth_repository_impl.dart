import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mens/features/auth/domain/auth_respository.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/auth/domain/user_profile.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('SharedPreferences not initialized'),
);

// Provider for the Auth Repository Implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepositoryImpl(dio, storage, prefs);
});

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  final SharedPreferences _prefs;
  static const _userProfileCacheKey = 'user_profile_cache';

  AuthRepositoryImpl(this._dio, this._storage, this._prefs);

  @override
  Future<UserProfile> login(String email, String password) async {
    // ... (login implementation remains the same)
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'];
        await _storage.write(key: 'jwt_token', value: token);
        if (kDebugMode) {
          print("Token stored successfully!");
        }
        final userProfile = await getUserData(forceRefresh: true);
        return userProfile;
      } else {
        throw Exception(
          'Login failed: Server response did not include a token.',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception(
        'Login failed due to a network error. Please check your connection and try again.',
      );
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected login error: $e");
      }
      throw Exception('An unexpected error occurred during login.');
    }
  }

  @override
  Future<void> register(RegisterState registerState) async {
    try {
      // Format the birth date into an ISO 8601 string if it exists
      final String? birthDate = registerState.ownerInfo.birthDate
          ?.toIso8601String();

      final response = await _dio.post(
        '/stores/register',
        data: {
          'email': registerState.profileInfo.email,
          'firstName': registerState.ownerInfo.firstName,
          'lastName': registerState.ownerInfo.lastName,
          'phoneNumber': registerState.ownerInfo.phoneNumber,
          'nationalId': registerState.ownerInfo.nationalId.isNotEmpty
              ? registerState.ownerInfo.nationalId
              : null,
          'birthDate': birthDate,
          'brandName': registerState.brandInfo.brandName,
          'brandDescription': registerState.brandInfo.description,
          'vat': registerState.brandInfo.vatRegistrationNumber.isNotEmpty
              ? registerState.brandInfo.vatRegistrationNumber
              : null,
          'categoryId': registerState.brandInfo.categoryId,
          'location': registerState.brandInfo.location,
          'password': registerState.profileInfo.password,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final serverMessage =
            response.data?['message'] ??
            'Registration failed with status: ${response.statusCode}';
        throw Exception(serverMessage);
      }

      if (kDebugMode) {
        print("Registration API call successful!");
      }
    } on DioException catch (e) {
      String errorMessage = 'A network error occurred during registration.';
      if (e.response != null) {
        errorMessage =
            e.response!.data?['message'] ??
            (e.response!.data?['errors']?.toString() ??
                'Registration failed with status: ${e.response!.statusCode}');
      }
      if (kDebugMode) {
        print("DioException during registration: $errorMessage");
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected registration error: $e");
      }
      throw Exception('An unexpected error occurred during registration.');
    }
  }

  @override
  Future<UserProfile> getUserData({bool forceRefresh = false}) async {
    // ... (getUserData implementation remains the same)
    if (!forceRefresh) {
      final cachedData = _prefs.getString(_userProfileCacheKey);
      if (cachedData != null) {
        try {
          if (kDebugMode) {
            print("Loading user profile from cache.");
          }
          return UserProfile.fromJson(jsonDecode(cachedData));
        } catch (e) {
          if (kDebugMode) {
            print("Failed to parse cached profile: $e. Clearing cache.");
          }
          await _prefs.remove(_userProfileCacheKey);
        }
      } else {
        if (kDebugMode) {
          print("No user profile found in cache.");
        }
      }
    } else {
      if (kDebugMode) {
        print("Force refreshing user profile (skipping cache).");
      }
    }

    if (kDebugMode) {
      print("Fetching user profile from API.");
    }
    try {
      final response = await _dio.get('/auth/me');
      if (response.statusCode == 200 && response.data['data'] != null) {
        //final userProfile = UserProfile.fromJson(response.data['data']);
        // ✅ ADD/VERIFY TRY-CATCH HERE
        try {
          final userProfile = UserProfile.fromJson(response.data['data']);
          // Cache the fetched data
          await _prefs.setString(
            _userProfileCacheKey,
            jsonEncode(userProfile.toJson()),
          );
          print("User profile cached successfully.");
          return userProfile;
        } catch (e, stackTrace) {
          // ✅ LOG THE PARSING ERROR AND THE DATA
          print("!!! FAILED TO PARSE UserProfile JSON !!!");
          print("Error: $e");
          print("StackTrace: $stackTrace");
          print(
            "Received Data: ${response.data['data']}",
          ); // Log the exact data
          throw Exception(
            'Failed to parse user data after fetching.',
          ); // Re-throw a specific error
        }
      } else {
        throw Exception(
          'Failed to fetch user data: Invalid response structure.',
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print(
          "DioException fetching user data: ${e.response?.statusCode} - ${e.message}",
        );
      }
      if (e.response?.statusCode == 401) {
        await logout();
        throw Exception('Session expired. Please log in again.');
      }
      throw Exception(
        'Could not fetch user data. Please check your connection.',
      );
    } catch (e) {
      if (kDebugMode) {
        print("Unexpected error fetching user data: $e");
      }
      throw Exception('An unexpected error occurred while fetching user data.');
    }
  }

  @override
  Future<void> logout() async {
    // ... (logout implementation remains the same)
    try {
      await _storage.delete(key: 'jwt_token');
      await _prefs.remove(_userProfileCacheKey);
      if (kDebugMode) {
        print("Token and cache cleared!");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during logout: $e");
      }
    }
  }
}
