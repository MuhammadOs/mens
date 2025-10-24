import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/profile/data/store_repository.dart';

class ShopInfoData {
  final String shopName;
  final String vatNumber;
  final int? categoryId;
  final String description;
  final String location;
  final String? image;

  ShopInfoData({
    required this.shopName,
    required this.vatNumber,
    this.categoryId,
    required this.description,
    required this.location,
    this.image,
  });

  ShopInfoData copyWith({
    String? shopName,
    String? vatNumber,
    int? categoryId,
    String? description,
    String? location,
    String? image,
  }) {
    return ShopInfoData(
      shopName: shopName ?? this.shopName,
      vatNumber: vatNumber ?? this.vatNumber,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      location: location ?? this.location,
      image: image ?? this.image,
    );
  }
}

// Provider for the notifier
final shopInfoNotifierProvider =
    NotifierProvider<ShopInfoNotifier, AsyncValue<ShopInfoData>>(
      ShopInfoNotifier.new,
    );

class ShopInfoNotifier extends Notifier<AsyncValue<ShopInfoData>> {
  @override
  AsyncValue<ShopInfoData> build() {
    // Ideally, fetch initial data from user profile or dedicated endpoint
    final userProfile = ref.watch(authNotifierProvider).asData?.value;
    if (userProfile?.store != null) {
      final store = userProfile!.store!;
      return AsyncValue.data(
        ShopInfoData(
          shopName: store.brandName,
          vatNumber: store.vat ?? '',
          categoryId: store.categoryId,
          description: store.brandDescription ?? '',
          location: store.location ?? '',
        ),
      );
    }
    // Fallback if no store data available initially (might show loading/error)
    return const AsyncValue.loading(); // Or fetch from a specific /stores/{id} endpoint
  }

  Future<void> saveChanges(ShopInfoData updatedData) async {
    state = const AsyncValue.loading();
    final userProfile = ref.read(authNotifierProvider).asData?.value;
    final storeId = userProfile?.store?.id;

    if (storeId == null) {
      state = AsyncValue.error(
        "Cannot save: Store ID not found.",
        StackTrace.current,
      );
      return;
    }

    try {
      final repo = ref.read(shopRepositoryProvider);
      final savedData = await repo.updateShopInfo(storeId, updatedData);
      // On success, update the state with the potentially modified data from response
      state = AsyncValue.data(savedData);
      print("Shop information saved successfully!");
      // Refresh the main user profile to ensure all parts of the app reflect the changes instantly
      ref.read(authNotifierProvider.notifier).refreshProfile();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateShopCategory(int? categoryId) {
    // Only update if the current state has data
    if (state is AsyncData<ShopInfoData>) {
      final currentData = state.asData!.value;
      state = AsyncValue.data(currentData.copyWith(categoryId: categoryId));
    }
  }

  Future<void> updateBrandImage(XFile imageFile) async {
    final currentState = state.asData?.value;
    final userProfile = ref.read(authNotifierProvider).asData?.value;
    final storeId = userProfile?.store?.id;

    if (currentState == null || storeId == null) {
      if (kDebugMode) {
        print("Cannot update image: current state or storeId is null.");
      }
      return;
    }

    // Store the previous state explicitly typed
    final previousState = AsyncValue<ShopInfoData>.data(currentState);

    // Set loading state, preserving previous data
    // ignore: invalid_use_of_internal_member
    state = AsyncValue<ShopInfoData>.loading().copyWithPrevious(previousState);

    try {
      final repo = ref.read(shopRepositoryProvider);
      final newImageUrl = await repo.updateStoreImage(storeId, imageFile);

      // Update the state with the new image URL
      final updatedData = currentState.copyWith(image: newImageUrl);
      state = AsyncValue.data(updatedData);
      if (kDebugMode) {
        print("Brand image updated successfully!");
      }

      // Refresh the main user profile
      ref.read(authNotifierProvider.notifier).refreshProfile();
    } catch (e, st) {
      if (kDebugMode) {
        print("Error updating brand image: $e");
      }
      // Revert to previous data on error, but keep the error information
      state = AsyncValue<ShopInfoData>.error(e, st).copyWithPrevious(
        previousState,
      ); // ignore: invalid_use_of_internal_member
    }
  }
}
