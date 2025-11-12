import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';

// Simple data class for order information
class _OrderData {
  final String id;
  final String customerName;
  final String items;
  final String price;
  final String date;
  final String status;

  _OrderData({
    required this.id,
    required this.customerName,
    required this.items,
    required this.price,
    required this.date,
    required this.status,
  });
}

class OrdersScreen extends HookConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);

    // Placeholder data
    final List<_OrderData> allOrders = [
      _OrderData(
        id: "#12345",
        customerName: "Sarah Johnson",
        items: "Ceramic Bowl Set x2",
        price: "\$68.00",
        date: "Sep 28, 2025",
        status: l10n.orderStatusPending,
      ),
      _OrderData(
        id: "#12344",
        customerName: "Mike Brown",
        items: "Woven Scarf x1",
        price: "\$45.00",
        date: "Sep 27, 2025",
        status: l10n.orderStatusShipped,
      ),
      _OrderData(
        id: "#12343",
        customerName: "Emma Davis",
        items: "Table Runner x1",
        price: "\$85.00",
        date: "Sep 25, 2025",
        status: l10n.ordersDelivered,
      ),
      _OrderData(
        id: "#12342",
        customerName: "Chris Lee",
        items: "Leather Wallet",
        price: "\$35.00",
        date: "Sep 24, 2025",
        status: l10n.ordersDelivered,
      ),
    ];

    // State for the filter
    final selectedFilter = useState(l10n.ordersTotal);

    // Logic to filter the list
    final filteredOrders = selectedFilter.value == l10n.ordersTotal
        ? allOrders
        : allOrders
              .where((order) => order.status == selectedFilter.value)
              .toList();

    // Data for the summary cards
    final summaryCards = [
      {
        'label': l10n.ordersTotal,
        'value': allOrders.length.toString(),
        'color': theme.colorScheme.primary,
      },
      {
        'label': l10n.ordersPending,
        'value': allOrders
            .where((o) => o.status == l10n.orderStatusPending)
            .length
            .toString(),
        'color': Colors.orange,
      },
      {
        'label': l10n.ordersDelivered,
        'value': allOrders
            .where((o) => o.status == l10n.ordersDelivered)
            .length
            .toString(),
        'color': Colors.green,
      },
      {
        'label': l10n.orderStatusShipped,
        'value': allOrders
            .where((o) => o.status == l10n.orderStatusShipped)
            .length
            .toString(),
        'color': Colors.blue,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: summaryCards.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cardData = summaryCards[index];
                final label = cardData['label'] as String;

                return SizedBox(
                  width: 120, // Give each card a fixed width
                  child: _SummaryCard(
                    label: label,
                    value: cardData['value'] as String,
                    onTap: () => selectedFilter.value = label,
                    isActive: selectedFilter.value == label,
                    activeColor: cardData['color'] as Color,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // The rest of the list remains the same
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredOrders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return _OrderListItem(order: filteredOrders[index]);
            },
          ),
        ],
      ),
    );
  }
}

// ✅ MODIFIED: Added onTap and isActive properties for interactivity.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    this.onTap,
    this.isActive = false,
    this.activeColor,
  });
  final String label, value;
  final VoidCallback? onTap;
  final bool isActive;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine colors based on whether the card is active
    final backgroundColor = isActive
        ? activeColor ?? theme.colorScheme.primary
        : theme.colorScheme.surface;
    final textColor = isActive
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ IMPLEMENTED WIDGET
class _OrderListItem extends ConsumerWidget {
  const _OrderListItem({required this.order});
  final _OrderData order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    // Determine color and icon based on status
    final (IconData icon, Color color) = switch (order.status) {
      _ when order.status == l10n.orderStatusPending => (
        Icons.watch_later_outlined,
        Colors.orange,
      ),
      _ when order.status == l10n.orderStatusShipped => (
        Icons.local_shipping_outlined,
        Colors.blue,
      ),
      _ when order.status == l10n.ordersDelivered => (
        Icons.check_circle_outline,
        Colors.green,
      ),
      _ => (Icons.help_outline, Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                    Text(
                      order.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(order.customerName, style: theme.textTheme.bodyLarge),
          Text(
            order.items,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 8),
          Text(
            order.price,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                order.date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    /* TODO: Navigate to order details screen */
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(
                      0.1,
                    ),
                    foregroundColor: theme.colorScheme.onSurface,
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.orderDetails,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
