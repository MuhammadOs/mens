import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/user/cart/cart.dart';
import 'package:mens/features/user/cart/notifiers/cart_notifier.dart';
import 'package:mens/features/user/orders/data/order_repository.dart';
import 'package:mens/features/user/orders/domain/order_models.dart';
import 'package:mens/shared/widgets/app_back_button.dart';
import 'package:mens/core/localization/l10n_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  final List<CartItem> items;
  const CheckoutScreen({super.key, required this.items});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _paymentMethod = 0; // 0 = Cash, 1 = Card
  bool _isLoading = false;

  // Controllers for address
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _flatController = TextEditingController();
  final _notesController = TextEditingController();

  double get total => widget.items.fold(0, (sum, item) => sum + item.subtotal);

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _flatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checkoutTitle),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppBackButton(
            outlined: true,
            iconColor: theme.appBarTheme.foregroundColor ?? Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(theme, l10n.orderSummary),
            const SizedBox(height: 12),
            _buildOrderSummary(theme),

            const SizedBox(height: 24),
            _buildSectionTitle(theme, l10n.paymentMethod),
            const SizedBox(height: 12),
            _buildPaymentMethod(theme),

            const SizedBox(height: 24),
            _buildSectionTitle(theme, l10n.shippingAddress),
            const SizedBox(height: 12),
            _buildShippingForm(theme),

            const SizedBox(height: 32),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handlePlaceOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 2,
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        l10n.placeOrder,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    final l10n = ref.read(l10nProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          ...widget.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quantity Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "${item.quantity}x",
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Title
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Price
                  Text(
                    "\$${item.subtotal.toStringAsFixed(2)}",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.cartTotal,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(ThemeData theme) {
    final l10n = ref.read(l10nProvider);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRadioTile(theme, 0, l10n.cash, FontAwesomeIcons.moneyBill),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
          _buildRadioTile(
            theme,
            1,
            l10n.creditCard,
            FontAwesomeIcons.creditCard,
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile(
    ThemeData theme,
    int value,
    String title,
    IconData icon, {
    bool enabled = true, // Add this optional parameter
  }) {
    return RadioListTile<int>(
      value: value,
      groupValue: _paymentMethod,
      // If enabled is false, onChanged is null, disabling the tile
      onChanged: enabled
          ? (val) => setState(() => _paymentMethod = val!)
          : null,
      activeColor: theme.colorScheme.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: enabled
                ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                : theme.disabledColor,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: enabled ? null : theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm(ThemeData theme) {
    final l10n = ref.read(l10nProvider);
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(l10n.city, _cityController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(l10n.street, _streetController)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTextField(l10n.building, _buildingController),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(l10n.floor, _floorController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField(l10n.flat, _flatController)),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(l10n.additionalNotes, _notesController, maxLines: 3),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        alignLabelWithHint: maxLines > 1,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Future<void> _handlePlaceOrder() async {
    final l10n = ref.read(l10nProvider);
    // Basic validation
    if (_cityController.text.isEmpty || _streetController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.fillRequiredFields)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(orderRepositoryProvider);

      // Construct Shipping Address String
      final shippingAddress =
          "${_cityController.text}, ${_streetController.text}, Bldg: ${_buildingController.text}, Floor: ${_floorController.text}, Flat: ${_flatController.text}";

      // Map CartItems to OrderItemRequests
      final orderItems = widget.items
          .map(
            (item) => OrderItemRequest(
              productId:
                  int.tryParse(item.id.toString()) ??
                  0, // Assuming item.id is usable as productId
              quantity: item.quantity,
            ),
          )
          .toList();

      // Get storeId from the first item (assuming all items are from same store or single store logic)
      final storeId = widget.items.isNotEmpty ? widget.items.first.storeId : 0;

      final request = OrderRequest(
        storeId: storeId,
        items: orderItems,
        paymentMethod: _paymentMethod == 0 ? "Cash" : "CreditCard",
        shippingAddress: shippingAddress,
        notes: _notesController.text,
      );

      print("Attempting to create order with payload: ${request.toJson()}");

      final response = await repository.createOrder(request);

      if (mounted) {
        // Clear Cart
        ref.read(cartNotifierProvider.notifier).clear();

        setState(() => _isLoading = false);
        _showSuccessDialog(response.id.toString());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showSuccessDialog(String orderId) {
    final theme = Theme.of(context);
    final l10n = ref.read(l10nProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FontAwesomeIcons.circleCheck,
                  size: 48,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.orderPlaced,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.orderIdDisplay(orderId),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Pop Dialog
                    Navigator.pop(context);
                    // Pop Checkout
                    Navigator.pop(context);
                    // Check if we can pop back further (to user home)
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(l10n.backToShopping),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
