import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/notifiers/auth_notifier.dart';
import '../data/cart_model.dart';
import '../data/cart_repository.dart';

final cartNotifierProvider =
    AsyncNotifierProvider<CartNotifier, List<CartItem>>(CartNotifier.new);

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    final authState = ref.watch(authNotifierProvider);
    final repository = ref.read(cartRepositoryProvider);

    // Determine current user ID (0 for guest)
    final userId = authState.value?.userId ?? 0;

    // If logged in, check if we need to merge guest cart
    if (userId != 0) {
      await _checkForGuestMerge(repository, userId);
    }

    return repository.fetchCart(userId);
  }

  /// Merges guest cart (id=0) into user cart if guest cart is not empty
  Future<void> _checkForGuestMerge(
    CartRepository repository,
    int userId,
  ) async {
    try {
      final guestCart = await repository.fetchCart(0);
      if (guestCart.isNotEmpty) {
        final userCart = await repository.fetchCart(userId);

        // Create a map for easier merging by ID
        final mergedMap = <String, CartItem>{};

        for (final item in userCart) {
          mergedMap[item.id] = item;
        }

        for (final guestItem in guestCart) {
          if (mergedMap.containsKey(guestItem.id)) {
            // Update quantity if exists
            final existing = mergedMap[guestItem.id]!;
            mergedMap[guestItem.id] = CartItem(
              id: existing.id,
              title: existing.title,
              price: existing.price,
              image: existing.image,
              storeId: existing.storeId,
              quantity: existing.quantity + guestItem.quantity,
            );
          } else {
            // Add new item
            mergedMap[guestItem.id] = guestItem;
          }
        }

        final mergedList = mergedMap.values.toList();

        // Save merged cart to user
        await repository.saveCart(userId, mergedList);

        // Clear guest cart
        await repository.clearCart(0);
      }
    } catch (e) {
      // Log error but don't block loading
      print('Error merging carts: $e');
    }
  }

  Future<void> addItem(CartItem item) async {
    final currentState = state.value ?? [];
    final newState = List<CartItem>.from(currentState);

    final index = newState.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      final existing = newState[index];
      newState[index] = CartItem(
        id: existing.id,
        title: existing.title,
        price: existing.price,
        image: existing.image,
        storeId: existing.storeId,
        quantity: existing.quantity + item.quantity,
      );
    } else {
      newState.add(item);
    }

    state = AsyncValue.data(newState);
    await _saveCart(newState);
  }

  Future<void> removeItem(String itemId) async {
    final currentState = state.value ?? [];
    final newState = currentState.where((item) => item.id != itemId).toList();

    state = AsyncValue.data(newState);
    await _saveCart(newState);
  }

  Future<void> incrementQuantity(String itemId) async {
    final currentState = state.value ?? [];
    final newState = currentState.map((item) {
      if (item.id == itemId) {
        return CartItem(
          id: item.id,
          title: item.title,
          price: item.price,
          image: item.image,
          storeId: item.storeId,
          quantity: item.quantity + 1,
        );
      }
      return item;
    }).toList();

    state = AsyncValue.data(newState);
    await _saveCart(newState);
  }

  Future<void> decrementQuantity(String itemId) async {
    final currentState = state.value ?? [];
    final newState = <CartItem>[];

    for (final item in currentState) {
      if (item.id == itemId) {
        if (item.quantity > 1) {
          newState.add(
            CartItem(
              id: item.id,
              title: item.title,
              price: item.price,
              image: item.image,
              storeId: item.storeId,
              quantity: item.quantity - 1,
            ),
          );
        }
        // If 1, do strictly what? Usually keep at 1 or remove?
        // UI often manages "remove if 0", but here decrement usually stops at 1.
        // Let's keep strict "decrement > 1". If user wants to remove, they use remove button.
        else {
          newState.add(item);
        }
      } else {
        newState.add(item);
      }
    }

    state = AsyncValue.data(newState);
    await _saveCart(newState);
  }

  Future<void> clear() async {
    state = const AsyncValue.data([]);
    await _saveCart([]);
  }

  Future<void> _saveCart(List<CartItem> items) async {
    final authState = ref.read(authNotifierProvider);
    final userId = authState.value?.userId ?? 0;
    final repository = ref.read(cartRepositoryProvider);
    await repository.saveCart(userId, items);
  }
}
