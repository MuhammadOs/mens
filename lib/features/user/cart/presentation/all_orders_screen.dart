import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/cart/presentation/order_details_screen.dart';

class AllOrdersScreen extends ConsumerWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(l10n.ordersTitle)), // Localized
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
                border: Border.all(color: theme.colorScheme.onSurface),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Localized Item format
                      Text(l10n.orderItemFormat(1, "Product Title")),
                      Text(l10n.orderItemFormat(1, "Product Title")),
                      Text(l10n.orderItemFormat(1, "Product Title")),
                      const Text("......"),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            // Localized Total Price
                            l10n.orderTotalPrice("89.97 \$"),
                          ),
                          Text(
                            // Localized Status
                            l10n.orderStatusLabel(l10n.statusDelivered),
                          ),
                        ],
                      ),
                      Text(
                        // Localized ID
                        l10n.orderIdLabel("16541651"),
                      ),
                    ],
                  ),
                  // The Number Badge
                  Positioned(
                    left: -25,
                    top: -25,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: theme.colorScheme.primary,
                      child: Text(
                        "${index + 1}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
