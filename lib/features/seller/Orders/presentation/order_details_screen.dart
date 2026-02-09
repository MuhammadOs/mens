import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/seller/Orders/data/order_model.dart';
import 'package:mens/features/seller/Orders/notifiers/orders_notifier.dart';

import 'package:skeletonizer/skeletonizer.dart';

class OrderDetailsScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends ConsumerState<OrderDetailsScreen> {
  String? selectedStatus;

  // Mock order for skeleton loading
  static final _dummyOrder = Order(
    id: 12345,
    orderNumber: '12345',
    userId: 1,
    storeId: 1,
    storeName: 'Loading Store',
    customerName: 'Loading Customer',
    customerEmail: 'loading@example.com',
    customerPhone: '+1 234 567 8900',
    status: 'Pending',
    totalAmount: 0.0,
    items: List.generate(
      3,
      (index) => OrderItem(
        id: index,
        productId: index,
        productName: 'Loading Product Name $index',
        productImage: '',
        quantity: 1,
        price: 0.0,
        subtotal: 0.0,
      ),
    ),
    shippingAddress: 'Loading Address Line 1\nLoading Address Line 2',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );

  void _updateOrderStatus(Order order, String newStatus) async {
    try {
      await ref.read(updateOrderStatusProvider((order.id, newStatus)).future);
      if (mounted) {
        setState(() {
          selectedStatus = newStatus;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(
          context,
        ).pop(true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getStatusIcon(String status) {
    return switch (status.toLowerCase()) {
      'pending' => FontAwesomeIcons.clock,
      'confirmed' => FontAwesomeIcons.checkCircle,
      'processing' => FontAwesomeIcons.spinner,
      'shipped' => FontAwesomeIcons.truck,
      'delivered' => FontAwesomeIcons.circleCheck,
      'cancelled' => FontAwesomeIcons.ban,
      _ => FontAwesomeIcons.questionCircle,
    };
  }

  Color _getStatusColor(String status) {
    return switch (status.toLowerCase()) {
      'pending' => Colors.orange,
      'confirmed' => Colors.blue,
      'processing' => Colors.purple,
      'shipped' => Colors.indigo,
      'delivered' => Colors.green,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);
    final orderAsync = ref.watch(sellerOrderDetailsProvider(widget.orderId));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Order #${widget.orderId}',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: orderAsync.when(
        data: (order) => _buildContent(context, order, theme),
        loading: () => Skeletonizer(
          enabled: true,
          child: _buildContent(context, _dummyOrder, theme),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.circleExclamation,
                size: 48,
                color: Colors.orange.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'Could not load order details',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.refresh(sellerOrderDetailsProvider(widget.orderId)),
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Order order, ThemeData theme) {
    final currentStatus = selectedStatus ?? order.status;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Timeline / Header
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(currentStatus).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _getStatusColor(currentStatus).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getStatusIcon(currentStatus),
                        size: 16,
                        color: _getStatusColor(currentStatus),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentStatus.toUpperCase(),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: _getStatusColor(currentStatus),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(order.createdAt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Store Info & Payment Method
          Row(
            children: [
              Expanded(
                child: _InfoTile(
                  label: 'Store',
                  value: order.storeName,
                  icon: FontAwesomeIcons.store,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoTile(
                  label: 'Payment',
                  value: order.paymentMethod ?? 'N/A',
                  icon: FontAwesomeIcons.creditCard,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (order.notes != null && order.notes!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.noteSticky,
                        size: 16,
                        color: Colors.amber.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    order.notes!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Order Items
          Text(
            'Items Ordered',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final item = order.items[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withOpacity(0.1),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.productImage.isNotEmpty
                          ? Image.network(
                              item.productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      FontAwesomeIcons.image,
                                      color: theme.hintColor,
                                      size: 24,
                                    ),
                                  ),
                            )
                          : Center(
                              child: Icon(
                                FontAwesomeIcons.box,
                                color: theme.hintColor,
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // Financial Summary
          _FinancialRow(
            label: 'Subtotal',
            value: '\$${_calculateSubtotal(order.items).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          _FinancialRow(
            label: 'Shipping',
            value: 'Free',
            valueColor: Colors.green,
          ),
          const SizedBox(height: 16),
          _FinancialRow(
            label: 'Total',
            value: '\$${order.totalAmount.toStringAsFixed(2)}',
            isTotal: true,
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // Customer Info
          Text(
            'Customer Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _CustomerInfoRow(
                  icon: FontAwesomeIcons.user,
                  value: order.customerName,
                ),
                if (order.customerEmail != null &&
                    order.customerEmail!.isNotEmpty) ...[
                  const Divider(height: 24, thickness: 0.5),
                  _CustomerInfoRow(
                    icon: FontAwesomeIcons.envelope,
                    value: order.customerEmail!,
                  ),
                ],
                if (order.customerPhone != null &&
                    order.customerPhone!.isNotEmpty) ...[
                  const Divider(height: 24, thickness: 0.5),
                  _CustomerInfoRow(
                    icon: FontAwesomeIcons.phone,
                    value: order.customerPhone!,
                  ),
                ],
                const Divider(height: 24, thickness: 0.5),
                _CustomerInfoRow(
                  icon: FontAwesomeIcons.locationDot,
                  value: order.shippingAddress,
                  isMultiline: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Update Status Action
          if (currentStatus.toLowerCase() != 'delivered' &&
              currentStatus.toLowerCase() != 'cancelled')
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  _showStatusUpdateSheet(context, order);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Update Order Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showStatusUpdateSheet(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Update Status',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  [
                        'Pending',
                        'Confirmed',
                        'Processing',
                        'Delivered',
                        'Cancelled',
                      ]
                      .where(
                        (status) =>
                            status.trim().toLowerCase() !=
                            (selectedStatus ?? order.status)
                                .trim()
                                .toLowerCase(),
                      )
                      .map(
                        (status) => ActionChip(
                          avatar: Icon(
                            _getStatusIcon(status),
                            size: 16,
                            color: _getStatusColor(status),
                          ),
                          label: Text(status),
                          onPressed: () {
                            Navigator.pop(context);
                            _updateOrderStatus(order, status);
                          },
                          backgroundColor: _getStatusColor(
                            status,
                          ).withOpacity(0.05),
                          side: BorderSide(
                            color: _getStatusColor(status).withOpacity(0.2),
                          ),
                          labelStyle: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  double _calculateSubtotal(List<OrderItem> items) {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }
}

class _FinancialRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _FinancialRow({
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = isTotal
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: style?.copyWith(color: isTotal ? null : theme.hintColor),
        ),
        Text(
          value,
          style: style?.copyWith(
            color: valueColor ?? (isTotal ? theme.colorScheme.primary : null),
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CustomerInfoRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool isMultiline;

  const _CustomerInfoRow({
    required this.icon,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: isMultiline
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: theme.hintColor.withOpacity(0.7)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            maxLines: isMultiline ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
