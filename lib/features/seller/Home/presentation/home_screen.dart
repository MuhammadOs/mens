import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Home/presentation/home_drawer.dart';
import 'package:mens/features/seller/Orders/data/order_model.dart';
import 'package:mens/features/seller/Orders/notifiers/orders_notifier.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;

    return Scaffold(
      // The drawer will be the side menu
      drawer: const HomeDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh recent orders
          ref.invalidate(ordersProvider((page: 1, pageSize: 5, status: 'pending')));
          // Refresh profile
          await ref.read(authNotifierProvider.notifier).refreshProfile();
          // Wait a bit to show the spinner
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // SliverAppBar for the custom header
              SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                pinned: true,
                automaticallyImplyLeading:
                    false, // We'll handle the drawer icon manually
                title: Row(
                  children: [
                    Builder(
                      builder: (context) {
                        return IconButton(
                          icon: Icon(
                            FontAwesomeIcons.bars,
                            color: colorScheme.onSurface,
                          ),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${l10n.homeWelcomeBack} ${userProfile?.firstName ?? "partner"}",
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      FontAwesomeIcons.bell,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () {
                      /* TODO: Navigate to notifications */
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
  
              // Body content
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Recent Orders Section
                    _buildSectionHeader(context, l10n.homeRecentOrders),
                    const SizedBox(height: 16),
                    _buildRecentOrdersList(),
                    const SizedBox(height: 64),
                    // Dashboard Grid Section
                    _buildDashboardGrid(context, l10n),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildRecentOrdersList() {
    return SizedBox(
      height: 160,
      child: Consumer(
        builder: (context, ref, child) {
          final ordersAsync = ref.watch(
            ordersProvider((page: 1, pageSize: 5, status: 'pending')),
          );

          return ordersAsync.when(
            data: (response) {
              if (response.orders.isEmpty) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Container(
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: Colors.green.withOpacity(0.1),
                           shape: BoxShape.circle,
                         ),
                         child: const Icon(FontAwesomeIcons.check, color: Colors.green),
                       ),
                       const SizedBox(width: 16),
                       Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             "No pending orders",
                             style: Theme.of(context).textTheme.titleMedium?.copyWith(
                               fontWeight: FontWeight.bold,
                               color: Colors.green.shade800,
                             ),
                           ),
                           const SizedBox(height: 4),
                           Text(
                              "You're all caught up!",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade600,
                              ),
                           ),
                         ],
                       )
                    ],
                  ),
                );
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: response.orders.length,
                itemBuilder:
                    (context, index) => _OrderCard(order: response.orders[index]),
              );
            },
            loading:
                () => Skeletonizer(
                  enabled: true,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder:
                        (context, index) => _OrderCard(
                          order: SellerOrderSummary(
                            id: 12345,
                            totalAmount: 0.0,
                            status: 'Pending',
                            itemCount: 0,
                            orderDate: DateTime.now(),
                          ),
                        ),
                  ),
                ),
            error:
                (error, stack) => Center(
                  child: Text(
                    'Error: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                title: l10n.homeStats,
                icon: FontAwesomeIcons.chartPie,
                color: Colors.green.shade100,
                iconColor: Colors.green,
                onTap: () {
                  context.push('/statistics');
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                title: l10n.homeOrders,
                icon: FontAwesomeIcons.boxesStacked,
                color: Colors.purple.shade100,
                iconColor: Colors.purple,
                onTap: () {
                  context.push('/orders');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DashboardCard(
                title: l10n.homeProducts,
                icon: FontAwesomeIcons.cubes,
                color: Colors.blue.shade100,
                iconColor: Colors.blue,
                onTap: () {
                  context.push('/products');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final SellerOrderSummary order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    
    // Format date nicely
    final dateStr = order.orderDate != null 
        ? "${order.orderDate!.day}/${order.orderDate!.month}/${order.orderDate!.year}"
        : "";

    return InkWell(
      onTap: () {
        context.push('/orders/${order.id}');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 300,
        margin: const EdgeInsets.only(right: 16),
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
                  "#${order.id}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        size: 14,
                        color: Colors.orange.shade800,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.status.toUpperCase(),
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // We don't have customer name in summary, so showing date
            Text(dateStr, style: theme.textTheme.bodyMedium),
            Text(
              "${order.itemCount} items",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "\$${order.totalAmount.toStringAsFixed(2)}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/orders/${order.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.orderDetails,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



// Placeholder widget for a dashboard grid item
class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color,
              child: Icon(icon, size: 30, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
