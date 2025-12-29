import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/features/seller/Statistics/data/statistics_model.dart';
import 'package:mens/features/seller/Statistics/notifiers/statistics_notifier.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;
    final storeId = userProfile?.store?.id;
    final stats = ref.watch(statisticsProvider(storeId));

    // Dummy data for skeleton loading
    final dummyStats = StatisticsResponse(
      totalSales: 0.0,
      totalOrders: 0,
      totalProducts: 0,
      totalCustomers: 0,
      monthlyOverview: List.generate(
        6,
        (index) => MonthlyOverview(
          year: 2024,
          month: index + 1,
          monthName: 'Month',
          sales: 500.0,
          orders: 10,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statisticsTitle)),
      body: storeId == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Store not found', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Please ensure you are logged in as a seller with an active store.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : stats.when(
              loading: () => Skeletonizer(
                enabled: true,
                child: _buildDashboard(context, dummyStats, l10n, theme, storeId, ref),
              ),
              error: (err, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 48, color: colorScheme.error),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        err.toString(),
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(statisticsProvider(storeId)),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (data) => _buildDashboard(context, data, l10n, theme, storeId, ref),
            ),
    );
  }

  Widget _buildDashboard(
    BuildContext context, 
    StatisticsResponse data, 
    dynamic l10n, 
    ThemeData theme, 
    int? storeId,
    WidgetRef ref,
  ) {
     return RefreshIndicator(
        onRefresh: () async {
           if (storeId != null) {
             return ref.refresh(statisticsProvider(storeId).future);
           }
        },
        // We will handle RefreshIndicator inside the parent or pass a callback.
        // Let's modify the signature to accept 'onRefresh'.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Key Metrics Row 1
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l10n.totalSales,
                      value: "\$${data.totalSales.toStringAsFixed(2)}",
                      change: data.totalOrders > 0 
                          ? "+${((data.totalSales / (data.totalOrders == 0 ? 1 : data.totalOrders)) * 10).toInt()}%" 
                          : "0%", 
                      icon: FontAwesomeIcons.sackDollar,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: l10n.orders,
                      value: "${data.totalOrders}",
                      change: "+${data.totalOrders}",
                      icon: FontAwesomeIcons.boxesStacked,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Key Metrics Row 2
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: l10n.products,
                      value: "${data.totalProducts}",
                      change: "+${data.totalProducts}",
                      icon: FontAwesomeIcons.tags,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      label: l10n.newCustomers,
                      value: "${data.totalCustomers}",
                      change: "+${data.totalCustomers}",
                      icon: FontAwesomeIcons.users,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Chart Section
              // For Skeleton, we want to show it even if empty list (using dummy data)
              if (data.monthlyOverview.isNotEmpty) ...[
                Text(
                  "Sales Trend",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(20),
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
                  ),
                  child: _MonthlySalesChart(data.monthlyOverview),
                ),
                const SizedBox(height: 24),
              ],

              // Derived Metrics
              Text(
                 "Insights",
                 style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _InsightRow(
                      label: "Avg. Order Value",
                      value: "\$${(data.totalOrders > 0 ? (data.totalSales / data.totalOrders) : 0).toStringAsFixed(2)}",
                      icon: FontAwesomeIcons.basketShopping,
                      color: Colors.teal,
                    ),
                    const Divider(height: 32),
                    _InsightRow(
                      label: "Sales per Customer",
                      value: "\$${(data.totalCustomers > 0 ? (data.totalSales / data.totalCustomers) : 0).toStringAsFixed(2)}",
                      icon: FontAwesomeIcons.userTag,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Monthly Breakdown List
               Text(
                l10n.monthlyOverview,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                     ...data.monthlyOverview.asMap().entries.map((entry) {
                        final overview = entry.value;
                        final isLast = entry.key == data.monthlyOverview.length - 1;
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              title: Text(
                                "${overview.monthName} ${overview.year}",
                                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$${overview.sales.toStringAsFixed(2)}",
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    "${overview.orders} orders",
                                    style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 0, indent: 20, endIndent: 20),
                          ],
                        );
                     }),
                  ],
                ),
              ),
            ],
          ),
        ),
     ); 
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.color,
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
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
               // Placeholder for trend icon if needed
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          const SizedBox(height: 8),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.green.withOpacity(0.1),
               borderRadius: BorderRadius.circular(8),
             ),
             child: Text(
               change, 
               style: theme.textTheme.labelSmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
             ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _InsightRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _MonthlySalesChart extends StatelessWidget {
  final List<MonthlyOverview> data;

  const _MonthlySalesChart(this.data);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data.isEmpty) return const SizedBox();

    // Find max Y for scaling
    double maxY = 0;
    for (var d in data) {
      if (d.sales > maxY) maxY = d.sales;
    }
    // Add some buffer
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
             getTooltipColor: (_) => theme.colorScheme.inverseSurface,
             getTooltipItem: (group, groupIndex, rod, rodIndex) {
               return BarTooltipItem(
                 '\$${rod.toY.toStringAsFixed(2)}',
                 TextStyle(color: theme.colorScheme.onInverseSurface, fontWeight: FontWeight.bold),
               );
             },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[value.toInt()].monthName.substring(0, 3),
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.dividerColor.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.sales,
                color: theme.colorScheme.primary,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                   show: true,
                   toY: maxY,
                   color: theme.colorScheme.primary.withOpacity(0.05),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
