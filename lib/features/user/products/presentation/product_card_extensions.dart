import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/features/user/cart/cart.dart';

extension ProductCartExtensions on Product {
  /// Maps a Domain Product to a Cart Item safely
  CartItem? toCartItem() {    
    return CartItem(
      id: id.toString(),
      title: name,
      price: price, // Assumes price is already a double in Product
      image: primaryImageUrl ?? '', 
      storeId: storeId,
      quantity: 1,
      // Add other fields if your CartItem supports them (e.g., brand, size)
    );
  }
}