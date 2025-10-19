import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';

// A simple data model for our user profile
class UserProfileData {
  final String fullName;
  final String email;
  final String phone;
  final String location;
  final String? nationalId;
  final DateTime? birthDate;

  UserProfileData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.location,
    required this.nationalId,
    required this.birthDate,
  });

  UserProfileData copyWith({
    String? username,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? nationalId,
    DateTime? birthDate
  }) {
    return UserProfileData(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      nationalId: nationalId ?? this.nationalId,
      birthDate: birthDate ?? this.birthDate
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
        fullName: userProfile?.fullName ?? "Partner Name",
        email: userProfile?.email ?? "Partner Email",
        phone: userProfile?.phoneNumber ?? "Partner Phone number",
        location: userProfile?.store?.location ?? "Patner location",
        nationalId: userProfile?.nationalId ?? "national id",
        birthDate: userProfile?.birthDate ?? DateTime.now()
      ),
    );
  }

  Future<void> saveChanges({
    required UserProfileData updatedData,
  }) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(updatedData);
      if (kDebugMode) {
        print("Profile saved successfully!");
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
