import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/user/brands/domain/brand.dart';
import 'package:mens/features/seller/Products/domain/product.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';

abstract class UserRepository {
  Future<List<Product>> getAllProducts();
  
  Future<PaginatedResponse<Product>> getAllProductsPaginated({
    PaginationParams? pagination,
    String? categoryId,
    String? subCategoryId,
    String? storeId,
  });

  Future<List<Brand>> getAllBrands();

  Future<PaginatedResponse<Brand>> getAllBrandsPaginated({
    PaginationParams? pagination,
    String? categoryId,
  });

  // --- NEW METHOD ---
  Future<PaginatedResponse<Product>> getProductsByBrandPaginated({
    required int brandId,
    required PaginationParams pagination,
  });
}

final adminRepositoryProvider = Provider<UserRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return AdminRepositoryImpl(dio);
});

class AdminRepositoryImpl implements UserRepository {
  final Dio _dio;
  AdminRepositoryImpl(this._dio);

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200 && response.data['items'] is List) {
        final List<dynamic> data = response.data['items'];
        return data.map((json) => Product.fromJson(json)).toList();
      }
      throw Exception('Failed to load all products');
    } on DioException {
      throw Exception('Network error fetching all products.');
    }
  }

  @override
  Future<PaginatedResponse<Product>> getAllProductsPaginated({
    PaginationParams? pagination,
    String? categoryId,
    String? subCategoryId,
    String? storeId,
  }) async {
    final paginationParams = pagination ?? const PaginationParams();

    final queryParams = <String, dynamic>{
      'page': paginationParams.page,
      'pageSize': paginationParams.pageSize,
    };

    if (categoryId != null) queryParams['categoryId'] = categoryId;
    if (subCategoryId != null) queryParams['subCategoryId'] = subCategoryId;
    if (storeId != null) queryParams['storeId'] = storeId;

    try {
      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return PaginatedResponse.fromJsonTyped<Product>(
          response.data as Map<String, dynamic>,
          Product.fromJson,
        );
      }

      // Fallback logic for Store endpoints
      if ((response.statusCode == 500 || response.statusCode == null) &&
          storeId != null) {
        return _attemptStoreFallback(storeId, queryParams);
      }

      throw Exception('Failed to load all products');
    } on DioException catch (e) {
      // Fallback on Dio Error (500)
      if (e.response?.statusCode == 500 && storeId != null) {
        try {
          return await _attemptStoreFallback(storeId, queryParams);
        } catch (_) {
          // fall through
        }
      }
      throw Exception('Network error fetching all products.');
    }
  }

  // --- NEW IMPLEMENTATION ---
  @override
  Future<PaginatedResponse<Product>> getProductsByBrandPaginated({
    required int brandId,
    required PaginationParams pagination,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'storeId': brandId, // Maps brandId to storeId
        'page': pagination.page,
        'pageSize': pagination.pageSize,
      };

      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return PaginatedResponse.fromJsonTyped<Product>(
          response.data as Map<String, dynamic>,
          Product.fromJson,
        );
      }
      
      throw Exception('Failed to load products for brand $brandId');
    } on DioException catch (e) {
      // Optional: Add specific error handling or fallback here if needed
      throw Exception('Network error fetching brand products: ${e.message}');
    }
  }

  @override
  Future<List<Brand>> getAllBrands() async {
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
        return PaginatedResponse.fromJsonTyped<Brand>(
          response.data as Map<String, dynamic>,
          Brand.fromJson,
        );
      }
      throw Exception('Failed to load all brands');
    } on DioException {
      throw Exception('Network error fetching all brands.');
    }
  }

  // Helper method to reduce code duplication for the store fallback logic
  Future<PaginatedResponse<Product>> _attemptStoreFallback(
    String storeId,
    Map<String, dynamic> queryParams,
  ) async {
    print('AdminRepository: Attempting fallback /stores/$storeId/products');
    final fallback = await _dio.get(
      '/stores/$storeId/products',
      queryParameters: queryParams,
    );
    if (fallback.statusCode == 200 && fallback.data is Map<String, dynamic>) {
      return PaginatedResponse.fromJsonTyped<Product>(
        fallback.data as Map<String, dynamic>,
        Product.fromJson,
      );
    }
    throw Exception('Fallback failed');
  }
}

// UI-Facing Providers
final allProductsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllProducts();
});

final allBrandsProvider = FutureProvider<List<Brand>>((ref) {
  return ref.watch(adminRepositoryProvider).getAllBrands();
});