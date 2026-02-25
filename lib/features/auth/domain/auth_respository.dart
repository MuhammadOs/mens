import 'package:mens/features/auth/domain/user_profile.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart';
import 'package:mens/features/user/profile/notifiers/edit_profile_notifier.dart';

abstract class AuthRepository {
  Future<UserProfile> login(String email, String password);
  Future<void> register(RegisterState registerState);
  Future<UserProfile> getUserData({bool forceRefresh = false});
  Future<void> updateProfile(UserProfileData data);
  Future<void> logout();
  Future<void> confirmEmail(String email, String token);
  Future<void> forgetPassword(String email);
  Future<void> resetPassword(String email, String token, String newPassword);
  Future<void> resendConfirmation(String email);
  Future<void> changePassword(String currentPassword, String newPassword);
}
