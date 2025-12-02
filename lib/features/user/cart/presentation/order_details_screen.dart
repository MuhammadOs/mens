import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';

class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(l10n.orderDetailsTitle)), // Localized
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Localized count
              l10n.orderItemsCount(4),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // List of items in this specific order
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.onSurface),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey,
                        ), // Image
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // Localized Item format
                              l10n.orderItemFormat(1, "Product title"),
                            ),
                            const Text("22.99 \$"),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Footer Summary
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.onSurface),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    // Localized Total
                    l10n.orderTotalLabel("120.99 \$"),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Localized Payment Method
                    l10n.paymentMethodLabel(l10n.paymentMethodCash),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Localized Address
                    l10n.shippingAddressLabel("6th of October"),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Localized ID
                    l10n.orderIdLabel("441654165"),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    // Localized Status
                    l10n.statusLabel(l10n.statusDelivered),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
