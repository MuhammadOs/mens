import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/user/profile/data/checkout_preferences_repository.dart';

final checkoutPreferencesProvider =
    NotifierProvider<CheckoutPreferencesNotifier, CheckoutPreferences>(
  CheckoutPreferencesNotifier.new,
);

class CheckoutPreferencesNotifier extends Notifier<CheckoutPreferences> {
  @override
  CheckoutPreferences build() {
    final repository = ref.watch(checkoutPreferencesRepoProvider);
    return repository.loadPreferences();
  }

  Future<void> savePreferences(CheckoutPreferences preferences) async {
    final repository = ref.read(checkoutPreferencesRepoProvider);
    await repository.savePreferences(preferences);
    state = preferences;
  }

  Future<void> updatePreferences({
    String? city,
    String? street,
    String? building,
    String? floor,
    String? flat,
    String? notes,
  }) async {
    final updatedPrefs = state.copyWith(
      city: city,
      street: street,
      building: building,
      floor: floor,
      flat: flat,
      notes: notes,
    );
    await savePreferences(updatedPrefs);
  }

  Future<void> clearPreferences() async {
    await savePreferences(const CheckoutPreferences());
  }
}
