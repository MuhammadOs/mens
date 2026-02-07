import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mens/features/auth/data/auth_repository_impl.dart';
import 'package:mens/features/auth/domain/user_profile.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/user/cart/data/cart_model.dart';
import 'package:mens/features/user/cart/data/cart_repository.dart';
import 'package:mens/features/user/cart/notifiers/cart_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('Guest starts with empty cart', () async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authNotifierProvider.overrideWith(FakeGuestAuthNotifier.new),
      ],
    );

    final cart = await container.read(cartNotifierProvider.future);
    expect(cart, isEmpty);
  });

  test('Guest adds item', () async {
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authNotifierProvider.overrideWith(FakeGuestAuthNotifier.new),
      ],
    );

    final item = CartItem(
      id: '1',
      title: 'Shirt',
      price: 10.0,
      image: 'img',
      storeId: 1,
      quantity: 1,
    );

    // Ensure initialized
    await container.read(cartNotifierProvider.future);

    await container.read(cartNotifierProvider.notifier).addItem(item);

    // Check state directly
    final cartState = container.read(cartNotifierProvider);

    final cart = cartState.value ?? [];
    expect(cart.length, 1, reason: 'Cart length should be 1');
    expect(cart.first.title, 'Shirt');
    expect(cart.first.quantity, 1);

    // Verify persistence
    final repo = container.read(cartRepositoryProvider);
    final stored = await repo.fetchCart(0);
    expect(stored.length, 1, reason: 'Stored cart length should be 1');
  });
}

class FakeGuestAuthNotifier extends AuthNotifier {
  @override
  AsyncValue<UserProfile?> build() {
    return const AsyncValue.data(null);
  }
}
