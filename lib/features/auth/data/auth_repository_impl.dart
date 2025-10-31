import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mens/features/auth/domain/auth_respository.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart';
import 'package:mens/features/seller/profile/notifiers/edit_profile_notifier.dart';
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
        final userProfile = await getUserData(forceRefresh: true);
        return userProfile;
      } else {
        throw Exception(
          'Login failed: Server response did not include a token.',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data['message'] != null) {
        final dynamic messageValue = e.response!.data['message'];
        throw Exception(messageValue?.toString() ?? 'Login failed');
      }
      throw Exception(
        'Login failed due to a network error. Please check your connection and try again.',
      );
    } catch (e) {
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
        final dynamic messageValue = response.data?['message'];
        final serverMessage =
            messageValue?.toString() ??
            'Registration failed with status: ${response.statusCode}';
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'A network error occurred during registration.';
      if (e.response != null) {
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
            (e.response!.data?['errors']?.toString() ??
                'Registration failed with status: ${e.response!.statusCode}');
      }
      throw Exception(errorMessage);
    } catch (e) {
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
          return UserProfile.fromJson(jsonDecode(cachedData));
        } catch (e) {
          await _prefs.remove(_userProfileCacheKey);
        }
      }
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
          return userProfile;
        } catch (e) {
          // Failed to parse user data after fetching
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
      if (e.response?.statusCode == 401) {
        await logout();
        throw Exception('Session expired. Please log in again.');
      }
      throw Exception(
        'Could not fetch user data. Please check your connection.',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching user data.');
    }
  }

  @override
  Future<void> updateProfile(UserProfileData data) async {
    try {
      // ✅ HELPER FUNCTION: Convert empty strings to null
      String? valueOrNull(String? value) {
        return (value == null || value.isEmpty) ? null : value;
      }

      // Create the request body, converting empty strings to null
      final requestData = {
        'email': valueOrNull(data.email),
        'firstName': valueOrNull(data.firstName),
        'lastName': valueOrNull(data.lastName),
        'phoneNumber': valueOrNull(data.phone),
        'nationalId': valueOrNull(data.nationalId),
        'birthDate': data.birthDate?.toIso8601String(),
      };

      final response = await _dio.put('/users/me', data: requestData);

      if (response.statusCode != 200 && response.statusCode != 204) {
        final dynamic messageValue = response.data?['message'];
        throw Exception(
          'Failed to update profile: ${messageValue?.toString() ?? 'Unknown error'}',
        );
      }

      await getUserData(forceRefresh: true);
    } on DioException catch (e) {
      String errorMessage = 'Network error updating profile.';
      if (e.response != null) {
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
            'Update failed: ${e.response!.statusCode}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred.');
    }
  }

  @override
  Future<void> logout() async {
    // ... (logout implementation remains the same)
    try {
      await _storage.delete(key: 'jwt_token');
      await _prefs.remove(_userProfileCacheKey);
    } catch (e) {
      // Error during logout
    }
  }
}
