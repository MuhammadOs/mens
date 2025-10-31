import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/seller/categories/domain/category.dart'; // Provides Category and SubCategory models

// --- Interface (Contract) ---
abstract class CategoryRepository {
  /// Fetches all main categories along with their subcategories.
  Future<List<Category>> getCategories();

  /// Fetches the subcategories for a specific main category ID.
  Future<List<SubCategory>> getSubCategories(int categoryId);
}

// --- Provider for the Repository Implementation ---
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  // Get the Dio instance configured with base URL and interceptors
  final dio = ref.watch(apiServiceProvider);
  return CategoryRepositoryImpl(dio);
});

// --- Implementation ---
class CategoryRepositoryImpl implements CategoryRepository {
  final Dio _dio;
  CategoryRepositoryImpl(this._dio);

  /// Implementation for fetching all categories.
  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200 && response.data is List) {
        // Parse the list of category JSON objects
        final List<dynamic> data = response.data;
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories: Invalid response format.');
      }
    } on DioException {
      // Handle network errors
      throw Exception('Failed to load categories due to network error.');
    } catch (e) {
      // Handle parsing errors
      throw Exception('Failed to parse categories.');
    }
  }

  /// Implementation for fetching subcategories by ID.
  @override
  Future<List<SubCategory>> getSubCategories(int id) async {
    try {
      final response = await _dio.get(
        '/categories/$id',
      ); // Use the category ID in the URL
      // Check if the response is successful and contains the 'subCategories' list
      if (response.statusCode == 200 &&
          response.data['subCategories'] is List) {
        final List<dynamic> data = response.data['subCategories'];
        // Parse the list of subcategory JSON objects
        return data.map((json) => SubCategory.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load subcategories for ID $id: Invalid response format.',
        );
      }
    } on DioException {
      // Handle network errors
      throw Exception('Failed to load subcategories due to network error.');
    } catch (e) {
      // Handle parsing errors
      throw Exception('Failed to parse subcategories.');
    }
  }
}

// --- UI-Facing Provider ---
/// A FutureProvider that fetches subcategories based on a given category ID.
/// It automatically handles loading and error states for the UI.
/// Use `ref.watch(subCategoriesProvider(categoryId))` in your widget.
final subCategoriesProvider = FutureProvider.family<List<SubCategory>, int>((
  ref,
  categoryId,
) async {
  // Get the repository instance
  final repository = ref.watch(categoryRepositoryProvider);
  // Call the repository method to fetch the data
  return repository.getSubCategories(categoryId);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getCategories(); // Fetches GET /api/categories
});
