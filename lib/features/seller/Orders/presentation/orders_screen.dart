import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/seller/Orders/notifiers/orders_notifier.dart';
import 'package:mens/features/seller/Orders/presentation/order_details_screen.dart';
import 'package:mens/features/seller/Orders/data/order_model.dart';

class OrdersScreen extends HookConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    
    // Status filter state
    final selectedStatus = useState<String>('All');
    final scrollController = useScrollController();

    // Watch the paginated provider
    final state = ref.watch(paginatedOrdersProvider);
    final notifier = ref.read(paginatedOrdersProvider.notifier);

    // Initial load and filter change handling
    useEffect(() {
      // Trigger load with current filter directly
      // This handles initial load AND updates when selectedStatus.value changes
      Future.microtask(() => notifier.setStatusFilter(selectedStatus.value));
      return null;
    }, [selectedStatus.value]);

    // Infinite scroll listener
    useEffect(() {
      void onScroll() {
        if (scrollController.hasClients && 
            scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
          notifier.loadNextPage();
        }
      }
      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController, notifier]);

    // Summary cards data/Tabs
    final summaryTabs = [
      'All', 'Pending', 'Confirmed', 'Processing', 'Shipped', 'Delivered', 'Cancelled'
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.ordersTitle),
      ),
      body: Column(
        children: [
          // Filter Tabs
          SizedBox(
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              scrollDirection: Axis.horizontal,
              itemCount: summaryTabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = summaryTabs[index];
                final isSelected = selectedStatus.value == status;
                return _FilterChip(
                  label: status,
                  isSelected: isSelected,
                  onTap: () {
                    selectedStatus.value = status;
                    if (scrollController.hasClients) {
                      scrollController.jumpTo(0);
                    }
                  },
                );
              },
            ),
          ),

          // Content
          Expanded(
            child: Builder(
              builder: (context) {
                // Formatting Error
                if (state.error != null && state.allItems.isEmpty) {
                   return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.circleExclamation, size: 48, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Failed to load orders', style: theme.textTheme.titleMedium),
                         TextButton(
                          onPressed: () => notifier.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                // Loading State (Initial)
                if (state.isLoading && state.allItems.isEmpty) {
                  return _buildSkeletonList(theme);
                }

                // Empty State
                if (!state.isLoading && state.allItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.boxOpen, size: 64, color: theme.dividerColor),
                        const SizedBox(height: 16),
                        Text('No orders found', style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor)),
                         TextButton(
                          onPressed: () => notifier.refresh(),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  );
                }

                // Data List
                return RefreshIndicator(
                  onRefresh: () async => notifier.refresh(),
                  child: ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    // Add 1 for the loading indicator at button if loading more
                    itemCount: state.allItems.length + (state.isLoadingMore ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == state.allItems.length) {
                         return const Center(child: Padding(
                           padding: EdgeInsets.all(16.0),
                           child: CircularProgressIndicator.adaptive(),
                         ));
                      }

                      final order = state.allItems[index];
                      return _OrderListItem(
                        order: order,
                        onDetails: () async {
                           final result = await Navigator.of(context).push<bool?>(
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsScreen(orderId: order.id),
                            ),
                          );
                          // Refresh if changes made (e.g. status update)
                          if (result == true) {
                            notifier.refresh();
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonList(ThemeData theme) {
    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (_, index) => _OrderListItem(
          order: SellerOrderSummary(
            id: 12345,
            orderDate: DateTime.now(),
            totalAmount: 150.00,
            status: 'Pending',
            itemCount: 3,
            storeName: 'Loading Store',
          ),
          onDetails: () {},
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected 
      ? theme.colorScheme.primary 
      : theme.colorScheme.surfaceContainerHighest;
    final onColor = isSelected 
      ? theme.colorScheme.onPrimary 
      : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.transparent),
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: onColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}


class _OrderListItem extends StatelessWidget {
  final SellerOrderSummary order;
  final VoidCallback onDetails;

  const _OrderListItem({required this.order, required this.onDetails});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Status helpers
    final (IconData icon, Color color) = switch (order.status.toLowerCase()) {
      'pending' => (FontAwesomeIcons.clock, Colors.orange),
      'confirmed' => (FontAwesomeIcons.circleCheck, Colors.blue),
      'processing' => (FontAwesomeIcons.spinner, Colors.purple),
      'shipped' => (FontAwesomeIcons.truck, Colors.indigo),
      'delivered' => (FontAwesomeIcons.circleCheck, Colors.green),
      'cancelled' => (FontAwesomeIcons.ban, Colors.red),
      _ => (FontAwesomeIcons.circleQuestion, Colors.grey),
    };

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onDetails,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${order.id}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 12, color: color),
                          const SizedBox(width: 6),
                          Text(
                            order.status,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Info Row
                Row(
                  children: [
                    // Date
                    _InfoItem(
                      icon: FontAwesomeIcons.calendar, 
                      text: order.orderDate != null 
                          ? '${order.orderDate!.day}/${order.orderDate!.month}/${order.orderDate!.year}' 
                          : 'N/A'
                    ),
                    const SizedBox(width: 24),
                    // Items
                    _InfoItem(
                      icon: FontAwesomeIcons.layerGroup, 
                      text: '${order.itemCount} Items'
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Footer: Total Price & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Amount', style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor)),
                        const SizedBox(height: 2),
                        Text(
                          '\$${order.totalAmount.toStringAsFixed(2)}', 
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios, size: 16, color: theme.hintColor.withOpacity(0.5)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.hintColor),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
      ],
    );
  }
}

