import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/admin/brands/domain/brand.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';

abstract class AdminRepository {
  Future<List<Product>> getAllProducts();
  Future<PaginatedResponse<Product>> getAllProductsPaginated({
    PaginationParams? pagination,
    String? categoryId,
    String? subCategoryId,
  });
  Future<List<Brand>> getAllBrands();
  Future<PaginatedResponse<Brand>> getAllBrandsPaginated({
    PaginationParams? pagination,
    String? categoryId,
  });
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return AdminRepositoryImpl(dio);
});

class AdminRepositoryImpl implements AdminRepository {
  final Dio _dio;
  AdminRepositoryImpl(this._dio);

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _dio.get('/products'); // Fetches all products
      if (response.statusCode == 200 && response.data['items'] is List) {
        final List<dynamic> data = response.data['items'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load all products');
    } on DioException {
      throw Exception('Network error fetching all products.');
    }
  }

  Future<PaginatedResponse<Product>> getAllProductsPaginated({
    PaginationParams? pagination,
    String? categoryId,
    String? subCategoryId,
  }) async {
    final paginationParams = pagination ?? const PaginationParams();

    try {
      final queryParams = <String, dynamic>{
        'page': paginationParams.page,
        'pageSize': paginationParams.pageSize,
      };

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      if (subCategoryId != null) {
        queryParams['subCategoryId'] = subCategoryId;
      }

      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Use the typed factory method to avoid type inference issues
        return PaginatedResponse.fromJsonTyped<Product>(
          responseData,
          Product.fromJson,
        );
      }
      throw Exception('Failed to load all products');
    } on DioException {
      throw Exception('Network error fetching all products.');
    }
  }

  @override
  Future<List<Brand>> getAllBrands() async {
    // NOTE: This is an assumed endpoint. Replace with your actual API endpoint.
    try {
      final response = await _dio.get('/stores');
      if (response.statusCode == 200 && response.data['items'] is List) {
        final List<dynamic> data = response.data['items'];
        return data.map((json) => Brand.fromJson(json)).toList();
      }
      throw Exception('Failed to load all brands');
    } on DioException {
      throw Exception('Network error fetching all brands.');
    }
  }

  @override
  Future<PaginatedResponse<Brand>> getAllBrandsPaginated({
    PaginationParams? pagination,
    String? categoryId,
  }) async {
    final paginationParams = pagination ?? const PaginationParams();

    try {
      final queryParams = <String, dynamic>{
        'page': paginationParams.page,
        'pageSize': paginationParams.pageSize,
      };

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _dio.get('/stores', queryParameters: queryParams);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        return PaginatedResponse.fromJsonTyped<Brand>(
          responseData,
          Brand.fromJson,
        );
      }
      throw Exception('Failed to load all brands');
    } on DioException {
      throw Exception('Network error fetching all brands.');
    }
  }
}

// UI-Facing Providers
final allProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllProducts();
});

final allBrandsProvider = FutureProvider<List<Brand>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllBrands();
});
