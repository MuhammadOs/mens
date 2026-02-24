import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/seller/Statistics/data/statistics_model.dart';
import 'package:mens/features/seller/Statistics/notifiers/statistics_notifier.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
String _egp(double value, String symbol) =>
    '${value.toStringAsFixed(2)} $symbol';

// ---------------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------------
class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  /// 0 = Sales chart, 1 = Orders chart
  int _chartMode = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;
    final storeId = userProfile?.store?.id;
    final stats = ref.watch(statisticsProvider(storeId));

    // Dummy data for skeleton loading
    final dummyStats = StatisticsResponse(
      totalSales: 0,
      totalOrders: 0,
      totalProducts: 0,
      totalCustomers: 0,
      monthlyOverview: List.generate(
        6,
        (i) => MonthlyOverview(
          year: 2024,
          month: i + 1,
          monthName: 'Month',
          sales: 500.0,
          orders: 10,
        ),
      ),
    );

    if (storeId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.statisticsTitle)),
        body: _NoStoreWidget(l10n: l10n, theme: theme),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statisticsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.refresh(statisticsProvider(storeId)),
          ),
        ],
      ),
      body: stats.when(
        loading: () => Skeletonizer(
          enabled: true,
          child: _buildDashboard(context, dummyStats, l10n, theme, storeId),
        ),
        error: (err, _) => _ErrorWidget(
          error: err.toString(),
          l10n: l10n,
          theme: theme,
          colorScheme: colorScheme,
          onRetry: () => ref.refresh(statisticsProvider(storeId)),
        ),
        data: (data) => _buildDashboard(context, data, l10n, theme, storeId),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    StatisticsResponse data,
    dynamic l10n,
    ThemeData theme,
    int? storeId,
  ) {
    final cs = theme.colorScheme;
    final egp = l10n.egpCurrency as String;

    // Derived metrics
    final avgOrder = data.totalOrders > 0
        ? data.totalSales / data.totalOrders
        : 0.0;
    final salesPerCust = data.totalCustomers > 0
        ? data.totalSales / data.totalCustomers
        : 0.0;
    final conversion = data.totalCustomers > 0
        ? (data.totalOrders / data.totalCustomers) * 100
        : 0.0;

    return RefreshIndicator(
      onRefresh: () async {
        if (storeId != null) {
          return ref.refresh(statisticsProvider(storeId).future);
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Stat Cards 2×2 ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: l10n.totalSales,
                          value: _egp(data.totalSales, egp),
                          icon: FontAwesomeIcons.sackDollar,
                          cardColor: const Color(0xFF10B981),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: l10n.orders,
                          value: '${data.totalOrders}',
                          icon: FontAwesomeIcons.boxesStacked,
                          cardColor: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: l10n.products,
                          value: '${data.totalProducts}',
                          icon: FontAwesomeIcons.tags,
                          cardColor: const Color(0xFF3B82F6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: l10n.newCustomers,
                          value: '${data.totalCustomers}',
                          icon: FontAwesomeIcons.users,
                          cardColor: const Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Chart Toggle + Chart ─────────────────────────────────
                  if (data.monthlyOverview.isNotEmpty) ...[
                    _SectionHeader(title: l10n.salesTrend as String),
                    const SizedBox(height: 12),
                    // Segment toggle
                    Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          _ChartTab(
                            label: l10n.salesLabel as String,
                            selected: _chartMode == 0,
                            onTap: () => setState(() => _chartMode = 0),
                            theme: theme,
                          ),
                          _ChartTab(
                            label: l10n.ordersChart as String,
                            selected: _chartMode == 1,
                            onTap: () => setState(() => _chartMode = 1),
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 260,
                      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _chartMode == 0
                          ? _BarChart(
                              data: data.monthlyOverview,
                              valueSelector: (m) => m.sales,
                              theme: theme,
                              tooltipPrefix: egp,
                              isCurrency: true,
                            )
                          : _BarChart(
                              data: data.monthlyOverview,
                              valueSelector: (m) => m.orders.toDouble(),
                              theme: theme,
                              tooltipPrefix: '',
                              isCurrency: false,
                            ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Insights ─────────────────────────────────────────────
                  _SectionHeader(title: l10n.insights as String),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _InsightRow(
                          label: l10n.avgOrderValue as String,
                          value: _egp(avgOrder, egp),
                          icon: FontAwesomeIcons.basketShopping,
                          color: const Color(0xFF0D9488),
                        ),
                        _InsightDivider(),
                        _InsightRow(
                          label: l10n.salesPerCustomer as String,
                          value: _egp(salesPerCust, egp),
                          icon: FontAwesomeIcons.userTag,
                          color: const Color(0xFF6366F1),
                        ),
                        _InsightDivider(),
                        _InsightRow(
                          label: l10n.conversionRate as String,
                          value: '${conversion.toStringAsFixed(1)}%',
                          icon: FontAwesomeIcons.chartLine,
                          color: const Color(0xFFF97316),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Monthly Breakdown ─────────────────────────────────────
                  _SectionHeader(title: l10n.monthlyOverview as String),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _MonthlyBreakdown(
                      overviews: data.monthlyOverview,
                      theme: theme,
                      egp: egp,
                      l10n: l10n,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat Card
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color cardColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardColor.withOpacity(0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cardColor.withOpacity(0.85), cardColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section Header
// ---------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Chart Tab Toggle
// ---------------------------------------------------------------------------
class _ChartTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ChartTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bar Chart
// ---------------------------------------------------------------------------
class _BarChart extends StatelessWidget {
  final List<MonthlyOverview> data;
  final double Function(MonthlyOverview) valueSelector;
  final ThemeData theme;
  final String tooltipPrefix;
  final bool isCurrency;

  const _BarChart({
    required this.data,
    required this.valueSelector,
    required this.theme,
    required this.tooltipPrefix,
    required this.isCurrency,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    double maxY = 0;
    for (final d in data) {
      final v = valueSelector(d);
      if (v > maxY) maxY = v;
    }
    maxY = (maxY * 1.25).ceilToDouble();
    if (maxY == 0) maxY = 100;

    final primary = theme.colorScheme.primary;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => theme.colorScheme.inverseSurface,
            getTooltipItem: (group, _, rod, __) {
              final v = rod.toY;
              final label = isCurrency
                  ? '${v.toStringAsFixed(0)} $tooltipPrefix'
                  : v.toInt().toString();
              return BarTooltipItem(
                label,
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i >= 0 && i < data.length) {
                  final name = data[i].monthName;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      name.length >= 3 ? name.substring(0, 3) : name,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                        fontSize: 11,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (_) => FlLine(
            color: theme.dividerColor.withOpacity(0.15),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: valueSelector(entry.value),
                gradient: LinearGradient(
                  colors: [Color.lerp(primary, Colors.white, 0.2)!, primary],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                width: 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: primary.withOpacity(0.06),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Insight Row & Divider
// ---------------------------------------------------------------------------
class _InsightRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InsightRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.7), color],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).dividerColor.withOpacity(0.5),
    );
  }
}

// ---------------------------------------------------------------------------
// Monthly Breakdown with Progress Bars
// ---------------------------------------------------------------------------
class _MonthlyBreakdown extends StatelessWidget {
  final List<MonthlyOverview> overviews;
  final ThemeData theme;
  final String egp;
  final dynamic l10n;

  const _MonthlyBreakdown({
    required this.overviews,
    required this.theme,
    required this.egp,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    if (overviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            l10n.noDataAvailable as String,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ),
      );
    }

    final maxSales = overviews
        .map((m) => m.sales)
        .reduce((a, b) => a > b ? a : b);
    final primary = theme.colorScheme.primary;

    return Column(
      children: overviews.asMap().entries.map((entry) {
        final i = entry.key;
        final m = entry.value;
        final isLast = i == overviews.length - 1;
        final ratio = maxSales > 0 ? m.sales / maxSales : 0.0;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${m.monthName} ${m.year}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${m.sales.toStringAsFixed(2)} $egp',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                          Text(
                            '${m.orders} ${l10n.orders}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio.toDouble(),
                      minHeight: 6,
                      backgroundColor: primary.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(
                          const Color(0xFF6366F1),
                          const Color(0xFF10B981),
                          ratio.toDouble(),
                        )!,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.dividerColor.withOpacity(0.4),
              ),
          ],
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Error & No-Store Widgets
// ---------------------------------------------------------------------------
class _ErrorWidget extends StatelessWidget {
  final String error;
  final dynamic l10n;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.error,
    required this.l10n,
    required this.theme,
    required this.colorScheme,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry as String),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoStoreWidget extends StatelessWidget {
  final dynamic l10n;
  final ThemeData theme;
  const _NoStoreWidget({required this.l10n, required this.theme});

  @override
  Widget build(BuildContext context) {
    final cs = theme.colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.storefront_rounded,
                size: 48,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.storeNotFound as String,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.storeNotFoundDesc as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
