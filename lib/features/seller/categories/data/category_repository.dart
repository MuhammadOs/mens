import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/seller/categories/domain/category.dart';

// --- Interface (Contract) ---
abstract class CategoryRepository {
  /// Fetches all main categories along with their nested subcategories.
  Future<List<Category>> getCategories();

  /// Fetches the subcategories for a specific main category ID.
  /// (Deprecated: Subcategories are now nested, but keeping for compatibility if needed)
  Future<List<Category>> getSubCategories(int categoryId);
}

// --- Provider for the Repository Implementation ---
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return CategoryRepositoryImpl(dio);
});

// --- Implementation ---
class CategoryRepositoryImpl implements CategoryRepository {
  final Dio _dio;
  CategoryRepositoryImpl(this._dio);

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: Invalid response format.');
      }
    } on DioException {
      throw Exception('Failed to load categories due to network error.');
    } catch (e) {
      throw Exception('Failed to parse categories.');
    }
  }

  @override
  Future<List<Category>> getSubCategories(int id) async {
    // With recursive categories, we can fetch all and find the specific one,
    // or call the specific endpoint if it still exists.
    try {
      final response = await _dio.get('/categories/$id');
      if (response.statusCode == 200 &&
          response.data['subCategories'] is List) {
        final List<dynamic> data = response.data['subCategories'];
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load subcategories for ID $id: Invalid response format.',
        );
      }
    } on DioException {
      throw Exception('Failed to load subcategories due to network error.');
    } catch (e) {
      throw Exception('Failed to parse subcategories.');
    }
  }
}

// --- UI-Facing Provider ---
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories();
});

/// Updated subCategoriesProvider to work with the recursive model
final subCategoriesProvider = FutureProvider.family<List<Category>, int>((
  ref,
  categoryId,
) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getSubCategories(categoryId);
});
