class CartItem {
  final String id;
  final String title;
  final double price;
  final String image;
  final int storeId;
  int quantity;

  CartItem({
    required this.id, 
    required this.title, 
    required this.price, 
    required this.image,
    required this.storeId, 
    this.quantity = 1
  });

  double get subtotal => price * quantity;
}