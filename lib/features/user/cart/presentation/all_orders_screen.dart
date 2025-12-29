import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/cart/presentation/order_details_screen.dart';
import 'package:mens/features/user/orders/presentation/providers/user_orders_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class AllOrdersScreen extends ConsumerWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);
    final ordersAsync = ref.watch(userOrdersProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: Text(l10n.ordersTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          return ref.refresh(userOrdersProvider.future);
        },
        child: ordersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                FontAwesomeIcons.boxOpen,
                                size: 48,
                                color: theme.colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "No orders yet",
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Your order history will appear here.",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final order = orders[index];
                return _OrderCard(order: order);
              },
            );
          },
          loading: () => Skeletonizer(
            enabled: true,
             child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) => const _OrderCardSkeleton(),
            ),
          ),
          error: (err, stack) => LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                 physics: const AlwaysScrollableScrollPhysics(),
                 child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Icon(FontAwesomeIcons.circleExclamation, size: 48, color: theme.colorScheme.error),
                           const SizedBox(height: 16),
                           Text("Failed to load orders", style: theme.textTheme.titleMedium),
                           const SizedBox(height: 8),
                           TextButton.icon(
                             onPressed: () => ref.refresh(userOrdersProvider),
                             icon: const Icon(FontAwesomeIcons.rotateRight),
                             label: const Text("Try Again"),
                           )
                        ],
                      ),
                    ),
                 ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final dynamic order; // Using dynamic or exact type if known (OrderSummary)

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(order.status);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailsScreen(orderId: order.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
             // Header
             Padding(
               padding: const EdgeInsets.all(16),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         "Order #${order.id}",
                         style: theme.textTheme.titleMedium?.copyWith(
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       const SizedBox(height: 4),
                       if (order.storeName != null)
                        Text(
                          order.storeName!.toUpperCase(),
                           style: theme.textTheme.labelSmall?.copyWith(
                             color: theme.colorScheme.primary,
                             fontWeight: FontWeight.bold,
                             letterSpacing: 0.5,
                           ),
                        ),
                     ],
                   ),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                     decoration: BoxDecoration(
                       color: statusColor.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(20),
                       border: Border.all(color: statusColor.withOpacity(0.2)),
                     ),
                     child: Text(
                       order.status,
                       style: theme.textTheme.labelSmall?.copyWith(
                         color: statusColor,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             
             Divider(height: 1, color: theme.colorScheme.outline.withOpacity(0.1)),
             
             // Body
             Padding(
               padding: const EdgeInsets.all(16),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         "Date",
                         style: theme.textTheme.labelMedium?.copyWith(
                           color: theme.colorScheme.onSurfaceVariant,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         DateFormat('MMM d, yyyy').format(order.orderDate ?? DateTime.now()),
                         style: theme.textTheme.bodyMedium?.copyWith(
                           fontWeight: FontWeight.w500,
                         ),
                       ),
                     ],
                   ),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.end,
                     children: [
                       Text(
                         "Total",
                         style: theme.textTheme.labelMedium?.copyWith(
                           color: theme.colorScheme.onSurfaceVariant,
                         ),
                       ),
                       const SizedBox(height: 4),
                       Text(
                         "\$${order.totalAmount.toStringAsFixed(2)}",
                         style: theme.textTheme.titleMedium?.copyWith(
                           fontWeight: FontWeight.bold,
                           color: theme.colorScheme.primary,
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
             ),
             
             // Footer
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               decoration: BoxDecoration(
                 color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                 borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
               ),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Text(
                     "${order.itemCount} items",
                     style: theme.textTheme.bodySmall?.copyWith(
                       color: theme.colorScheme.onSurfaceVariant,
                     ),
                   ),
                   Row(
                     children: [
                       Text(
                         "View Details",
                         style: theme.textTheme.labelMedium?.copyWith(
                           color: theme.colorScheme.primary,
                           fontWeight: FontWeight.bold,
                         ),
                       ),
                       const SizedBox(width: 4),
                       Icon(FontAwesomeIcons.chevronRight, size: 10, color: theme.colorScheme.primary),
                     ],
                   )
                 ],
               ),
             )
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _OrderCardSkeleton extends StatelessWidget {
  const _OrderCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
        height: 180,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(16),
        child: const Column(
          children: [
             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Bone.text(width: 80), Bone.circle(size: 24)]),
             Spacer(),
             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Bone.text(width: 60), Bone.text(width: 60)]),
          ],
        ),
    );
  }
}
