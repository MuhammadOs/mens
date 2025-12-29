class StatisticsResponse {
  final double totalSales;
  final int totalProducts;
  final int totalOrders;
  final int totalCustomers;
  final List<MonthlyOverview> monthlyOverview;

  StatisticsResponse({
    required this.totalSales,
    required this.totalProducts,
    required this.totalOrders,
    required this.totalCustomers,
    required this.monthlyOverview,
  });

  factory StatisticsResponse.fromJson(Map<String, dynamic> json) {
    return StatisticsResponse(
      totalSales: (json['totalSales'] as num?)?.toDouble() ?? 0.0,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalCustomers: (json['totalCustomers'] as num?)?.toInt() ?? 0,
      monthlyOverview:
          (json['monthlyOverview'] as List<dynamic>?)
              ?.map(
                (item) =>
                    MonthlyOverview.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'totalSales': totalSales,
    'totalProducts': totalProducts,
    'totalOrders': totalOrders,
    'totalCustomers': totalCustomers,
    'monthlyOverview': monthlyOverview.map((m) => m.toJson()).toList(),
  };
}

class MonthlyOverview {
  final int year;
  final int month;
  final String monthName;
  final double sales;
  final int orders;

  MonthlyOverview({
    required this.year,
    required this.month,
    required this.monthName,
    required this.sales,
    required this.orders,
  });

  factory MonthlyOverview.fromJson(Map<String, dynamic> json) {
    return MonthlyOverview(
      year: (json['year'] as num?)?.toInt() ?? 0,
      month: (json['month'] as num?)?.toInt() ?? 0,
      monthName: json['monthName'] ?? '',
      sales: (json['sales'] as num?)?.toDouble() ?? 0.0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'monthName': monthName,
    'sales': sales,
    'orders': orders,
  };
}
