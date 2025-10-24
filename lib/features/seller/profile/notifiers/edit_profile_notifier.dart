import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/features/auth/data/auth_repository_impl.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';

// A simple data model for our user profile
class UserProfileData {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? nationalId;
  final DateTime? birthDate;

  UserProfileData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.birthDate,
  });

  UserProfileData copyWith({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? nationalId,
    DateTime? birthDate,
  }) {
    return UserProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}

// Provider for our notifier
final editProfileNotifierProvider =
    NotifierProvider<EditProfileNotifier, AsyncValue<UserProfileData>>(
      EditProfileNotifier.new,
    );

class EditProfileNotifier extends Notifier<AsyncValue<UserProfileData>> {
  @override
  AsyncValue<UserProfileData> build() {
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;
    // In a real app, you would fetch this from a repository
    return AsyncValue.data(
      UserProfileData(
        firstName: userProfile?.firstName ?? "Partner first name",
        lastName: userProfile?.lastName ?? "Partner last name",
        email: userProfile?.email ?? "Partner Email",
        phone: userProfile?.phoneNumber ?? "Partner Phone number",
        nationalId: userProfile?.nationalId ?? "national id",
        birthDate: userProfile?.birthDate ?? DateTime.now(),
      ),
    );
  }

  Future<void> saveChanges({
    required UserProfileData updatedData,
    XFile? newImage, // This is for the *brand* image, not user profile pic
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(authRepositoryProvider);

      // 1. Save the text field data
      await repo.updateProfile(updatedData);

      // 2. Handle image upload (if it's still part of this screen)
      // Note: The API you provided is for /users/me, which doesn't take an image.
      // The image upload logic should be separate (e.g., in ShopInfoNotifier).
      // If you intended to upload the *user's* profile pic, you need a different API.
      if (newImage != null) {
        print(
          "Image update logic would go here, but /users/me doesn't support it.",
        );
        // await repo.updateUserAvatar(newImage); // Example
      }

      // 3. Update the local state with the saved data
      state = AsyncValue.data(updatedData);

      // 4. Refresh the main auth state to get the globally updated UserProfile
      ref.invalidate(authNotifierProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
