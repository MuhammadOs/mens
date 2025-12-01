import 'package:flutter/material.dart';
import 'package:mens/features/user/cart/presentation/order_details_screen.dart';

class AllOrdersScreen extends StatelessWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text("Your Orders")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrderDetailsScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "1 x Product Title",
                        style: TextStyle(color: Colors.white),
                      ),
                      const Text(
                        "1 x Product Title",
                        style: TextStyle(color: Colors.white),
                      ),
                      const Text(
                        "1 x Product Title",
                        style: TextStyle(color: Colors.white),
                      ),
                      const Text(
                        "......",
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Price: 89.97 \$",
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            "Order Status: Delivered",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const Text(
                        "Order ID: 16541651",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  // The Number Badge
                  Positioned(
                    left: -25,
                    top: -25,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
