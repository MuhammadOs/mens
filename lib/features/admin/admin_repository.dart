import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/admin/brands/domain/brand.dart';
import 'package:mens/features/seller/Products/domain/product.dart';

abstract class AdminRepository {
  Future<List<Product>> getAllProducts();
  Future<List<Brand>> getAllBrands();
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

  @override
  Future<List<Brand>> getAllBrands() async {
    // NOTE: This is an assumed endpoint. Replace with your actual API endpoint.
    try {
      final response = await _dio.get('/stores');
      if (response.statusCode == 200 && response.data is List) {
        // This mapping assumes the API returns a list matching the Brand model.
        // You may need to adjust this based on the actual API response.
        final List<dynamic> data = response.data;
        return data.map((json) => Brand.fromJson(json)).toList();
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