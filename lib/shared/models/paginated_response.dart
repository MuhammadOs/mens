import 'package:json_annotation/json_annotation.dart';

part 'paginated_response.g.dart';

/// Generic paginated response model that wraps any list of items with pagination metadata
@JsonSerializable(genericArgumentFactories: true, explicitToJson: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson<T>(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$PaginatedResponseToJson<T>(this, toJsonT);

  /// Factory method specifically for Product types to avoid type inference issues
  static PaginatedResponse<T> fromJsonTyped<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map((item) => fromJsonT(item as Map<String, dynamic>))
            .toList() ??
        [];

    return PaginatedResponse<T>(
      items: items,
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 10,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

/// Extension to provide useful pagination helper methods
extension PaginatedResponseExtension<T> on PaginatedResponse<T> {
  /// Whether there are more pages available
  bool get hasNextPage => page < totalPages;

  /// Whether there are previous pages available
  bool get hasPreviousPage => page > 1;

  /// Get the next page number (null if no next page)
  int? get nextPage => hasNextPage ? page + 1 : null;

  /// Get the previous page number (null if no previous page)
  int? get previousPage => hasPreviousPage ? page - 1 : null;

  /// Whether this is the first page
  bool get isFirstPage => page == 1;

  /// Whether this is the last page
  bool get isLastPage => page == totalPages;

  /// Get the starting item number for current page (1-based)
  int get startItem => (page - 1) * pageSize + 1;

  /// Get the ending item number for current page (1-based)
  int get endItem {
    final calculatedEnd = page * pageSize;
    return calculatedEnd > totalCount ? totalCount : calculatedEnd;
  }

  /// Get a summary string like "1-20 of 100 items"
  String get itemsSummary => '$startItem-$endItem of $totalCount items';
}
