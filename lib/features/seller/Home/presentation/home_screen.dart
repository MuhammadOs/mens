import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Home/presentation/home_drawer.dart';
import 'package:mens/features/seller/Orders/data/order_model.dart';
import 'package:mens/features/seller/Orders/notifiers/orders_notifier.dart';
import 'package:mens/features/seller/Statistics/notifiers/statistics_notifier.dart';
import 'package:skeletonizer/skeletonizer.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

String _greetingFor(DateTime now) {
  final h = now.hour;
  if (h < 12) return 'Good morning';
  if (h < 17) return 'Good afternoon';
  return 'Good evening';
}

String _formatDate(DateTime? dt) {
  if (dt == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}';
}

/// Returns themed color + icon for a given order status string.
({Color color, Color bg, IconData icon}) _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'confirmed':
      return (
        color: const Color(0xFF1565C0),
        bg: const Color(0xFFE3F2FD),
        icon: FontAwesomeIcons.solidCircleCheck,
      );
    case 'processing':
      return (
        color: const Color(0xFF6A1B9A),
        bg: const Color(0xFFF3E5F5),
        icon: FontAwesomeIcons.gear,
      );
    case 'shipped':
      return (
        color: const Color(0xFF00695C),
        bg: const Color(0xFFE0F2F1),
        icon: FontAwesomeIcons.truck,
      );
    case 'delivered':
      return (
        color: const Color(0xFF2E7D32),
        bg: const Color(0xFFE8F5E9),
        icon: FontAwesomeIcons.boxOpen,
      );
    case 'cancelled':
      return (
        color: const Color(0xFFC62828),
        bg: const Color(0xFFFFEBEE),
        icon: FontAwesomeIcons.ban,
      );
    default: // pending
      return (
        color: const Color(0xFFE65100),
        bg: const Color(0xFFFFF3E0),
        icon: FontAwesomeIcons.clock,
      );
  }
}

// ─── Main screen ──────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;
    final storeId = userProfile?.store?.id;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final now = DateTime.now();
    final greeting = _greetingFor(now);
    final firstName = userProfile?.firstName ?? 'Partner';

    // Avatar
    final brandImageUrl = userProfile?.store?.brandImage;
    final brandName = userProfile?.store?.brandName ?? 'B';
    final initials = brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B';
    final hasImage = brandImageUrl != null && brandImageUrl.isNotEmpty;

    return Scaffold(
      drawer: const HomeDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(
            ordersProvider((page: 1, pageSize: 5, status: 'pending')),
          );
          ref.invalidate(statisticsProvider(storeId));
          await ref.read(authNotifierProvider.notifier).refreshProfile();
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App bar ──────────────────────────────────────────────
              SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Row(
                  children: [
                    Builder(
                      builder: (ctx) => IconButton(
                        icon: Icon(
                          FontAwesomeIcons.bars,
                          size: 18,
                          color: cs.onSurface,
                        ),
                        onPressed: () => Scaffold.of(ctx).openDrawer(),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            greeting,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.50),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            firstName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Avatar → seller profile
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.sellerProfile),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.primary, width: 2),
                        image: hasImage
                            ? DecorationImage(
                                image: NetworkImage(brandImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: cs.primary.withValues(alpha: 0.10),
                      ),
                      child: !hasImage
                          ? Center(
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),

              // ── Body ─────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats banner
                    _StatsBanner(storeId: storeId),
                    const SizedBox(height: 24),

                    // Recent orders
                    _SectionHeader(
                      title: l10n.homeRecentOrders,
                      action: l10n.seeAll,
                      onAction: () => context.push(AppRoutes.orders),
                    ),
                    const SizedBox(height: 12),
                    _RecentOrdersList(),
                    const SizedBox(height: 24),

                    // Quick actions
                    _SectionHeader(title: 'Quick Actions'),
                    const SizedBox(height: 12),
                    _DashboardGrid(l10n: l10n),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Stats banner ──────────────────────────────────────────────────────────────

class _StatsBanner extends ConsumerWidget {
  final int? storeId;
  const _StatsBanner({required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider(storeId));
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return statsAsync.when(
      data: (stats) => _StatsRow(
        items: [
          _StatChipData(
            label: l10n?.salesLabel ?? "Sales",
            value: stats.totalSales.toStringAsFixed(0),
            icon: FontAwesomeIcons.chartLine,
            color: const Color(0xFF26A69A),
            onTap: () => context.push(AppRoutes.statistics),
          ),
          _StatChipData(
            label: l10n?.orders ?? 'Orders',
            value: '${stats.totalOrders}',
            icon: FontAwesomeIcons.boxesStacked,
            color: const Color(0xFF5C6BC0),
            onTap: () => context.push(AppRoutes.orders),
          ),
          _StatChipData(
            label: l10n?.products ?? 'Products',
            value: '${stats.totalProducts}',
            icon: FontAwesomeIcons.cubes,
            color: const Color(0xFF42A5F5),
            onTap: () => context.push(AppRoutes.products),
          ),
          _StatChipData(
            label: l10n?.customers ?? 'Customers',
            value: '${stats.totalCustomers}',
            icon: FontAwesomeIcons.users,
            color: const Color(0xFFFF7043),
            onTap: () {},
          ),
        ],
      ),
      loading: () => Skeletonizer(
        enabled: true,
        child: _StatsRow(
          items: List.generate(
            4,
            (_) => _StatChipData(
              label: 'Loading',
              value: '000',
              icon: FontAwesomeIcons.chartLine,
              color: cs.primary,
              onTap: () {},
            ),
          ),
        ),
      ),
      error: (_, __) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.error.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.triangleExclamation,
              size: 14,
              color: cs.error,
            ),
            const SizedBox(width: 8),
            Text(
              'Could not load statistics',
              style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChipData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _StatChipData({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _StatsRow extends StatelessWidget {
  final List<_StatChipData> items;
  const _StatsRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(child: _StatChip(data: items[i])),
          if (i < items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final _StatChipData data;
  const _StatChip({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: data.color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Icon(data.icon, size: 16, color: data.color),
            const SizedBox(height: 6),
            Text(
              data.value,
              style: theme.textTheme.titleSmall?.copyWith(
                color: data.color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              data.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent orders list ────────────────────────────────────────────────────────

class _RecentOrdersList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(
      ordersProvider((page: 1, pageSize: 5, status: 'pending')),
    );
    final theme = Theme.of(context);

    return SizedBox(
      height: 156,
      child: ordersAsync.when(
        data: (response) {
          if (response.orders.isEmpty) {
            return _EmptyOrdersState();
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: response.orders.length,
            itemBuilder: (context, index) =>
                _OrderCard(order: response.orders[index]),
          );
        },
        loading: () => Skeletonizer(
          enabled: true,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (_, __) => _OrderCard(
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
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                FontAwesomeIcons.circleXmark,
                color: theme.colorScheme.error,
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                'Could not load orders',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyOrdersState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.check,
              color: Colors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No pending orders',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "You're all caught up!",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.green.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Order card ────────────────────────────────────────────────────────────────

class _OrderCard extends ConsumerWidget {
  final SellerOrderSummary order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final style = _statusStyle(order.status);
    final dateStr = _formatDate(order.orderDate);

    return GestureDetector(
      onTap: () => context.push('/orders/${order.id}'),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.onSurface.withValues(alpha: 0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.id}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(style.icon, size: 9, color: style.color),
                      const SizedBox(width: 4),
                      Text(
                        order.status,
                        style: TextStyle(
                          color: style.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date + item count
            if (dateStr.isNotEmpty)
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.calendarDays,
                    size: 11,
                    color: cs.onSurface.withValues(alpha: 0.40),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.bagShopping,
                  size: 11,
                  color: cs.onSurface.withValues(alpha: 0.40),
                ),
                const SizedBox(width: 5),
                Text(
                  '${order.itemCount} ${order.itemCount == 1 ? "item" : "items"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // Total + view link
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'EGP ${order.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.orderDetails,
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Icon(
                      FontAwesomeIcons.arrowRight,
                      size: 10,
                      color: cs.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard grid ────────────────────────────────────────────────────────────

class _DashboardGrid extends StatelessWidget {
  final dynamic l10n;
  const _DashboardGrid({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Stats — full width
        _DashboardCard(
          title: l10n.homeStats,
          subtitle: 'Revenue & analytics',
          icon: FontAwesomeIcons.chartPie,
          color: const Color(0xFF26A69A),
          onTap: () => context.push(AppRoutes.statistics),
          fullWidth: true,
        ),
        const SizedBox(height: 12),
        // Orders + Products row
        Row(
          children: [
            Expanded(
              child: _DashboardCard(
                title: l10n.homeOrders,
                subtitle: 'Manage orders',
                icon: FontAwesomeIcons.boxesStacked,
                color: const Color(0xFF5C6BC0),
                onTap: () => context.push(AppRoutes.orders),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DashboardCard(
                title: l10n.homeProducts,
                subtitle: 'Your listings',
                icon: FontAwesomeIcons.cubes,
                color: const Color(0xFF42A5F5),
                onTap: () => context.push(AppRoutes.products),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Add Product — full width
        _DashboardCard(
          title: 'Add Product',
          subtitle: 'List a new item for sale',
          icon: FontAwesomeIcons.circlePlus,
          color: const Color(0xFF7E57C2),
          onTap: () => context.push(AppRoutes.addProduct),
          fullWidth: true,
          outlined: true,
        ),
      ],
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;
  final bool outlined;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: outlined ? Colors.transparent : cs.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: outlined
                  ? color.withValues(alpha: 0.40)
                  : cs.onSurface.withValues(alpha: 0.08),
            ),
            boxShadow: outlined
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: fullWidth ? 14 : 18,
            ),
            child: fullWidth
                ? Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(icon, size: 20, color: color),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: outlined ? color : cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.48),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.arrowRight,
                        size: 14,
                        color: outlined
                            ? color
                            : cs.onSurface.withValues(alpha: 0.30),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(icon, size: 20, color: color),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withValues(alpha: 0.48),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
