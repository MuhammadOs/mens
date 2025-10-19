import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/features/auth/data/auth_repository_impl.dart';

// Data models for each step's form data
class OwnerInfoData {
  String firstName;
  String lastName;
  String userName;
  String nationalId;
  DateTime? birthDate;
  String phoneNumber;

  OwnerInfoData({
    this.firstName = '',
    this.lastName = '',
    this.userName = '',
    this.nationalId = '',
    this.birthDate,
    this.phoneNumber = '',
  });

  OwnerInfoData copyWith({
    String? firstName,
    String? lastName,
    String? userName,
    String? nationalId,
    DateTime? birthDate,
    String? phoneNumber,
  }) {
    return OwnerInfoData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      userName: userName ?? this.userName,
      nationalId: nationalId ?? this.nationalId,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

class BrandInfoData {
  String brandName;
  String vatRegistrationNumber;
  int? categoryId;
  String description;
  String location;

  BrandInfoData({
    this.brandName = '',
    this.vatRegistrationNumber = '',
    this.categoryId,
    this.description = '',
    this.location = '',
  });

  BrandInfoData copyWith({
    String? brandName,
    String? vatRegistrationNumber,
    int? categoryId,
    String? description,
    String? location,
  }) {
    return BrandInfoData(
      brandName: brandName ?? this.brandName,
      vatRegistrationNumber: vatRegistrationNumber ?? this.vatRegistrationNumber,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      location: location ?? this.location,
    );
  }
}

class ProfileInfoData {
  String email;
  String password;
  String repeatPassword;
  XFile? brandImage;

  ProfileInfoData({
    this.email = '',
    this.password = '',
    this.repeatPassword = '',
    this.brandImage,
  });

  ProfileInfoData copyWith({
    String? email,
    String? password,
    String? repeatPassword,
    XFile? brandImage,
  }) {
    return ProfileInfoData(
      email: email ?? this.email,
      password: password ?? this.password,
      repeatPassword: repeatPassword ?? this.repeatPassword,
      brandImage: brandImage ?? this.brandImage,
    );
  }
}

// Full Registration State
class RegisterState {
  final int currentStep;
  final OwnerInfoData ownerInfo;
  final BrandInfoData brandInfo;
  final ProfileInfoData profileInfo;
  final AsyncValue<bool>
  registrationStatus; // To handle loading/error for final register

  RegisterState({
    this.currentStep = 0,
    OwnerInfoData? ownerInfo,
    BrandInfoData? brandInfo,
    ProfileInfoData? profileInfo,
    this.registrationStatus = const AsyncValue.data(false),
  }) : ownerInfo = ownerInfo ?? OwnerInfoData(),
       brandInfo = brandInfo ?? BrandInfoData(),
       profileInfo = profileInfo ?? ProfileInfoData();

  RegisterState copyWith({
    int? currentStep,
    OwnerInfoData? ownerInfo,
    BrandInfoData? brandInfo,
    ProfileInfoData? profileInfo,
    AsyncValue<bool>? registrationStatus,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      ownerInfo: ownerInfo ?? this.ownerInfo,
      brandInfo: brandInfo ?? this.brandInfo,
      profileInfo: profileInfo ?? this.profileInfo,
      registrationStatus: registrationStatus ?? this.registrationStatus,
    );
  }
}

// Notifier for the registration process
final registerNotifierProvider =
    NotifierProvider<RegisterNotifier, RegisterState>(RegisterNotifier.new);

class RegisterNotifier extends Notifier<RegisterState> {
  @override
  RegisterState build() {
    return RegisterState();
  }

  void nextStep() {
    if (state.currentStep < 2) {
      // Assuming 3 steps (0, 1, 2)
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updateOwnerInfo({
    String? firstName,
    String? lastName,
    String? userName,
    String? nationalId,
    DateTime? birthDate,
    String? phoneNumber,
  }) {
    state = state.copyWith(
      ownerInfo: state.ownerInfo.copyWith(
        firstName: firstName,
        lastName: lastName,
        userName: userName,
        nationalId: nationalId,
        birthDate: birthDate,
        phoneNumber: phoneNumber,
      ),
    );
  }

  void updateBrandInfo({
    String? brandName,
    String? vatRegistrationNumber,
    int? categoryId,
    String? description,
    String? location,
  }) {
    state = state.copyWith(
      brandInfo: state.brandInfo.copyWith(
        brandName: brandName,
        vatRegistrationNumber: vatRegistrationNumber,
        categoryId: categoryId,
        description: description,
        location: location,
      ),
    );
  }

  void updateProfileInfo({
    String? email,
    String? password,
    String? repeatPassword,
    XFile? brandImage,
  }) {
    state = state.copyWith(
      profileInfo: state.profileInfo.copyWith(
        email: email,
        password: password,
        repeatPassword: repeatPassword,
        brandImage: brandImage,
      ),
    );
  }

  // ✅ UPDATE THE REGISTER METHOD
  Future<void> register() async {
    state = state.copyWith(registrationStatus: const AsyncValue.loading());
    try {
      // Use the real repository
      await ref.read(authRepositoryProvider).register(state);

      // On success, update the status
      state = state.copyWith(registrationStatus: const AsyncValue.data(true));

    } catch (e, st) {
      // On failure, update the status with the error
      state = state.copyWith(registrationStatus: AsyncValue.error(e, st));
    }
  }
}
