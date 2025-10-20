import 'package:mens/features/auth/domain/user_profile.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart';
import 'package:mens/features/seller/profile/notifiers/edit_profile_notifier.dart';

abstract class AuthRepository {
  Future<UserProfile> login(String email, String password);
  Future<void> register(RegisterState registerState);
  Future<UserProfile> getUserData({bool forceRefresh = false});
  Future<void> updateProfile(UserProfileData data);
  Future<void> logout();
}