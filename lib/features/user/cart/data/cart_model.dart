class CartItem {
  final String id;
  final String title;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.id, 
    required this.title, 
    required this.price, 
    required this.image, 
    this.quantity = 1
  });

  double get subtotal => price * quantity;
}