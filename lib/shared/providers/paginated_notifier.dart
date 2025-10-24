import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';

/// Generic state class for paginated data
class PaginatedState<T> {
  final PaginatedResponse<T>? currentPage;
  final List<T> allItems;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasReachedEnd;

  const PaginatedState({
    this.currentPage,
    required this.allItems,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasReachedEnd = false,
  });

  /// Default constructor with empty items
  PaginatedState.initial() : this(allItems: <T>[]);

  PaginatedState<T> copyWith({
    PaginatedResponse<T>? currentPage,
    List<T>? allItems,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasReachedEnd,
  }) {
    return PaginatedState<T>(
      currentPage: currentPage ?? this.currentPage,
      allItems: allItems ?? this.allItems,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
    );
  }

  /// Create loading state
  PaginatedState<T> loading() {
    return copyWith(isLoading: true, error: null);
  }

  /// Create loading more state (for append operations)
  PaginatedState<T> loadingMore() {
    return copyWith(isLoadingMore: true, error: null);
  }

  /// Create success state with new data
  PaginatedState<T> success(
    PaginatedResponse<T> response, {
    bool append = false,
  }) {
    final newItems = append ? [...allItems, ...response.items] : response.items;

    return copyWith(
      currentPage: response,
      allItems: newItems,
      isLoading: false,
      isLoadingMore: false,
      error: null,
      hasReachedEnd: response.page >= response.totalPages,
    );
  }

  /// Create error state
  PaginatedState<T> failure(String errorMessage) {
    return copyWith(
      isLoading: false,
      isLoadingMore: false,
      error: errorMessage,
    );
  }

  /// Whether there's any data loaded
  bool get hasData => allItems.isNotEmpty;

  /// Whether we can load more data
  bool get canLoadMore => !hasReachedEnd && !isLoadingMore && error == null;
}

/// Abstract base class for paginated notifiers
abstract class PaginatedNotifier<T> extends Notifier<PaginatedState<T>> {
  @override
  PaginatedState<T> build() {
    return PaginatedState<T>.initial();
  }

  /// Fetch data for a specific page
  Future<PaginatedResponse<T>> fetchPage(PaginationParams params);

  /// Load the first page (replaces existing data)
  Future<void> loadFirstPage({PaginationParams? params}) async {
    final paginationParams = params ?? const PaginationParams();

    state = state.loading();

    try {
      final response = await fetchPage(paginationParams);
      state = state.success(response);
    } catch (e) {
      state = state.failure(e.toString());
    }
  }

  /// Load a specific page (replaces existing data)
  Future<void> loadPage(int page, {int? pageSize}) async {
    final params = PaginationParams(
      page: page,
      pageSize: pageSize ?? state.currentPage?.pageSize ?? 20,
    );

    await loadFirstPage(params: params);
  }

  /// Load the next page (appends to existing data)
  Future<void> loadNextPage() async {
    if (!state.canLoadMore) return;

    final currentPage = state.currentPage;
    if (currentPage == null) {
      await loadFirstPage();
      return;
    }

    final nextPageParams = PaginationParams(
      page: currentPage.page + 1,
      pageSize: currentPage.pageSize,
    );

    state = state.loadingMore();

    try {
      final response = await fetchPage(nextPageParams);
      state = state.success(response, append: true);
    } catch (e) {
      state = state.failure(e.toString());
    }
  }

  /// Refresh the current page
  Future<void> refresh() async {
    final currentPage = state.currentPage;
    if (currentPage != null) {
      await loadPage(currentPage.page, pageSize: currentPage.pageSize);
    } else {
      await loadFirstPage();
    }
  }

  /// Reset to initial state
  void reset() {
    state = PaginatedState<T>.initial();
  }
}
