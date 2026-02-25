import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/user/addresses/data/address_repository.dart';
import 'package:mens/features/user/addresses/domain/address.dart';

class AddressNotifier extends AsyncNotifier<List<Address>> {
  @override
  Future<List<Address>> build() async {
    return _fetchAddresses();
  }

  Future<List<Address>> _fetchAddresses() async {
    final repository = ref.read(addressRepositoryProvider);
    return repository.getAddresses();
  }

  Future<void> addAddress(Address address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(addressRepositoryProvider);
      await repository.addAddress(address);
      return _fetchAddresses();
    });
  }

  Future<void> updateAddress(int id, Address address) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(addressRepositoryProvider);
      await repository.updateAddress(id, address);
      return _fetchAddresses();
    });
  }

  Future<void> deleteAddress(int id) async {
    final previousState = state;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      try {
        final repository = ref.read(addressRepositoryProvider);
        await repository.deleteAddress(id);
        return _fetchAddresses();
      } catch (e) {
        state = previousState;
        rethrow;
      }
    });
  }

  Future<void> setDefaultAddress(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(addressRepositoryProvider);
      await repository.setDefaultAddress(id);
      return _fetchAddresses();
    });
  }
}

final addressNotifierProvider = AsyncNotifierProvider<AddressNotifier, List<Address>>(() {
  return AddressNotifier();
});
