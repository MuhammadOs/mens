import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_model.dart';
import '../../../auth/data/auth_repository_impl.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CartRepository(prefs);
});

class CartRepository {
  final SharedPreferences _prefs;

  CartRepository(this._prefs);

  /// Load cart items for a specific user ID
  Future<List<CartItem>> fetchCart(int userId) async {
    try {
      final key = 'cart_$userId';
      final jsonString = _prefs.getString(key);

      if (jsonString != null) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        return decoded.map((e) => CartItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      // Return empty list on error to prevent crashing
      return [];
    }
  }

  /// Save cart items for a specific user ID
  Future<void> saveCart(int userId, List<CartItem> items) async {
    try {
      final key = 'cart_$userId';
      final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());
      await _prefs.setString(key, jsonString);
    } catch (e) {
      // Log error or handle gracefully
    }
  }

  /// Clear cart for a specific user ID
  Future<void> clearCart(int userId) async {
    final key = 'cart_$userId';
    await _prefs.remove(key);
  }
}
