/// Parameters for pagination requests
class PaginationParams {
  final int page;
  final int pageSize;

  const PaginationParams({this.page = 1, this.pageSize = 20});

  /// Create pagination params from query parameters
  factory PaginationParams.fromQuery({int? page, int? pageSize}) {
    return PaginationParams(page: page ?? 1, pageSize: pageSize ?? 20);
  }

  /// Convert to query parameters map
  Map<String, dynamic> toQueryParams() {
    return {'page': page, 'pageSize': pageSize};
  }

  /// Create a copy with new values
  PaginationParams copyWith({int? page, int? pageSize}) {
    return PaginationParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  /// Create parameters for the next page
  PaginationParams nextPage() {
    return copyWith(page: page + 1);
  }

  /// Create parameters for the previous page
  PaginationParams previousPage() {
    return copyWith(page: page > 1 ? page - 1 : 1);
  }

  /// Create parameters for the first page
  PaginationParams firstPage() {
    return copyWith(page: 1);
  }

  @override
  String toString() => 'PaginationParams(page: $page, pageSize: $pageSize)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationParams &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          pageSize == other.pageSize;

  @override
  int get hashCode => page.hashCode ^ pageSize.hashCode;
}
