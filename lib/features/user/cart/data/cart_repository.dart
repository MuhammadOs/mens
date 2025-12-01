import 'package:flutter/foundation.dart';
import 'cart_model.dart';

/// Simple in-memory cart repository for demo/testing.
/// Uses a ValueNotifier so UI can listen without introducing large state management changes.
class CartRepository {
  CartRepository._privateConstructor();
  static final CartRepository instance = CartRepository._privateConstructor();

  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  void addItem(CartItem item) {
    final current = List<CartItem>.from(items.value);
    final existing = current.indexWhere(
      (e) => e.id == item.id || e.title == item.title,
    );
    if (existing >= 0) {
      current[existing].quantity += item.quantity;
    } else {
      current.add(item);
    }
    items.value = current;
  }

  void removeAt(int index) {
    final current = List<CartItem>.from(items.value);
    if (index >= 0 && index < current.length) {
      current.removeAt(index);
      items.value = current;
    }
  }

  void updateQuantity(int index, int quantity) {
    final current = List<CartItem>.from(items.value);
    if (index >= 0 && index < current.length) {
      current[index].quantity = quantity;
      items.value = current;
    }
  }

  void clear() {
    items.value = [];
  }
}
