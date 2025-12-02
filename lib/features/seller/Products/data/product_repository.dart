import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart'; // Provides apiServiceProvider (adjust path if needed)
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart'; // Provides Product model (adjust path if needed)
import 'package:mens/features/seller/Products/domain/product_image.dart';
import 'package:mens/shared/models/paginated_response.dart';
import 'package:mens/shared/models/pagination_params.dart';

// --- Interface (Contract) ---
abstract class ProductRepository {
  /// Fetches a list of products for the store, optionally filtered by category/subcategory.
  Future<List<Product>> getProducts({int? categoryId, int? subCategoryId});

  /// Fetches paginated products for the store, optionally filtered by category/subcategory.
  Future<PaginatedResponse<Product>> getProductsPaginated({
    PaginationParams? pagination,
    int? categoryId,
    int? subCategoryId,
  });

  /// Fetches details for a single product by its ID.
  Future<Product> getProductById(int productId);

  /// Adds a new product to the store.
  /// Images should be uploaded first using ImageUploadService.
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
    required List<ProductImage> images,
  });

  /// Updates an existing product (details and images).
  /// For new images: upload them first using ImageUploadService and provide imageUrl without id.
  /// For existing images: include the id field.
  Future<void> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
    required List<ProductImage> images,
  });

  Future<void> deleteProduct(int productId);
}

// --- Provider for the Repository Implementation ---
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  // Get the Dio instance configured with base URL and interceptors
  final dio = ref.watch(apiServiceProvider);
  // Pass the ref to the implementation to allow reading other providers (like AuthNotifier)
  return ProductRepositoryImpl(dio, ref);
});

// --- Implementation ---
class ProductRepositoryImpl implements ProductRepository {
  final Dio _dio;
  final Ref _ref; // Riverpod Ref to read other providers

  ProductRepositoryImpl(this._dio, this._ref);

  /// Fetches a list of products for the currently logged-in user's store.
  @override
  Future<List<Product>> getProducts({
    int? categoryId,
    int? subCategoryId,
  }) async {
    // Get storeId from the logged-in user's profile state
    final userProfile = _ref.read(authNotifierProvider).asData?.value;
    final storeId = userProfile?.store?.id;
    final role = userProfile?.role;
    if (storeId == null) {
      throw Exception('Store ID not found. Cannot fetch products.');
    }

    // Build query parameters ONLY for optional filters
    final queryParameters = <String, dynamic>{
      if (categoryId != null) 'categoryId': categoryId,
      if (subCategoryId != null) 'subCategoryId': subCategoryId,
    };

    try {
      // Use the endpoint structure: /stores/{storeId}/products
      final response = await _dio.get(
        '/stores/$storeId/products',
        queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      );

      // Check if the response contains the 'items' key and it's a list
      if (response.statusCode == 200 && response.data['items'] is List) {
        final List<dynamic> data = response.data['items'];
        // Parse each item in the list using the Product.fromJson factory
        var products = data.map((json) => Product.fromJson(json)).toList();

        // For StoreOwner (seller), set storeName to the seller's store name
        if (role == 'StoreOwner') {
          final sellerStoreName = userProfile?.store?.brandName;
          if (sellerStoreName != null) {
            products = products
                .map((p) => p.copyWith(storeName: sellerStoreName))
                .toList();
          }
        }
        // For user, keep the storeName from the product data

        return products;
      } else {
        throw Exception(
          'Failed to load products: Invalid response structure or missing "items" key.',
        );
      }
    } on DioException {
      // Handle Dio-specific errors (network, timeout, status codes)
      throw Exception('Failed to load products due to network error.');
    } catch (e) {
      // Handle potential JSON parsing errors or other unexpected issues
      throw Exception('Failed to parse products.');
    }
  }

  /// Fetches paginated products for the currently logged-in user's store.
  @override
  Future<PaginatedResponse<Product>> getProductsPaginated({
    PaginationParams? pagination,
    int? categoryId,
    int? subCategoryId,
  }) async {
    // Get storeId from the logged-in user's profile state
    final userProfile = _ref.read(authNotifierProvider).asData?.value;
    final storeId = userProfile?.store?.id;
    final role = userProfile?.role;
    if (storeId == null) {
      throw Exception('Store ID not found. Cannot fetch products.');
    }

    final paginationParams = pagination ?? const PaginationParams();

    // Build query parameters including pagination
    final queryParameters = <String, dynamic>{
      'page': paginationParams.page,
      'pageSize': paginationParams.pageSize,
      if (categoryId != null) 'categoryId': categoryId,
      if (subCategoryId != null) 'subCategoryId': subCategoryId,
    };

    try {
      // Use the endpoint structure: /stores/{storeId}/products
      final response = await _dio.get(
        '/stores/$storeId/products',
        queryParameters: queryParameters,
      );

      // Check if the response is valid and contains pagination structure
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        // Use the typed factory method to avoid type inference issues
        final paginatedResponse = PaginatedResponse.fromJsonTyped<Product>(
          responseData,
          Product.fromJson,
        );

        // For StoreOwner (seller), set storeName to the seller's store name
        var items = paginatedResponse.items;
        if (role == 'StoreOwner') {
          final sellerStoreName = userProfile?.store?.brandName;
          if (sellerStoreName != null) {
            items = items
                .map((p) => p.copyWith(storeName: sellerStoreName))
                .toList();
          }
        }
        // For user, keep the storeName from the product data

        return PaginatedResponse<Product>(
          items: items,
          page: paginatedResponse.page,
          pageSize: paginatedResponse.pageSize,
          totalCount: paginatedResponse.totalCount,
          totalPages: paginatedResponse.totalPages,
        );
      } else {
        throw Exception('Failed to load products: Invalid response structure.');
      }
    } on DioException {
      // Handle Dio-specific errors (network, timeout, status codes)
      throw Exception('Failed to load products due to network error.');
    } catch (e) {
      // Handle potential JSON parsing errors or other unexpected issues
      throw Exception('Failed to parse products.');
    }
  }

  /// Fetches details for a single product by its ID.
  @override
  Future<Product> getProductById(int productId) async {
    // Get storeId (assuming endpoint requires store context, e.g., /stores/{storeId}/products/{productId})
    // If endpoint is just /products/{productId}, remove storeId logic.
    try {
      // Adjust endpoint if necessary based on your API design
      final response = await _dio.get('/products/$productId');
      // OR: final response = await _dio.get('/products/$productId');

      if (response.statusCode == 200 && response.data != null) {
        // Assuming the response directly contains the product JSON
        // Add specific parsing if it's nested, e.g., response.data['data']
        return Product.fromJson(response.data);
      } else {
        throw Exception('Failed to load product details: Invalid response.');
      }
    } on DioException {
      throw Exception('Failed to load product details.');
    } catch (e) {
      throw Exception('Failed to parse product details.');
    }
  }

  /// Adds a new product using JSON with pre-uploaded images.
  @override
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
    required List<ProductImage> images,
  }) async {
    try {
      // Prepare the request body as JSON
      final requestBody = {
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
        'subCategoryId': subCategoryId,
        'images': images.map((img) => img.toJson()).toList(),
      };

      // Send POST request to the /products endpoint
      final response = await _dio.post('/products', data: requestBody);

      // Check for successful status codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        final dynamic messageValue = response.data?['message'];
        final serverMessage =
            messageValue?.toString() ??
            'Failed to add product: ${response.statusCode}';
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error adding product.';
      if (e.response != null) {
        final dynamic messageValue = e.response!.data?['message'];
        final dynamic errors = e.response!.data?['errors'];
        errorMessage =
            messageValue?.toString() ??
            errors?.toString() ??
            'Failed with status: ${e.response!.statusCode}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred while adding the product.');
    }
  }

  /// Updates an existing product (details and images) using JSON.
  @override
  Future<void> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
    required List<ProductImage> images,
  }) async {
    try {
      // Prepare the request body as JSON
      final requestBody = {
        'name': name,
        'description': description,
        'price': price,
        'stockQuantity': stockQuantity,
        'subCategoryId': subCategoryId,
        'images': images.map((img) => img.toJson()).toList(),
      };

      final response = await _dio.put(
        '/products/$productId',
        data: requestBody,
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final dynamic messageValue = response.data?['message'];
        final serverMessage =
            messageValue?.toString() ?? 'Update failed: ${response.statusCode}';
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error updating product.';
      if (e.response != null) {
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
            (e.response!.data?['errors']?.toString() ??
                'Update failed with status: ${e.response!.statusCode}');
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred while updating product.');
    }
  }

  @override
  Future<void> deleteProduct(int productId) async {
    try {
      final response = await _dio.delete(
        '/products/$productId', // Use the DELETE method
      );

      // Check for 200 (OK) or 204 (No Content) status
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete product: ${response.statusCode}');
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error deleting product.';
      if (e.response != null) {
        // Handle both string and non-string message types
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
            'Delete failed: ${e.response!.statusCode}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('An unexpected error occurred while deleting.');
    }
  }
}

// --- UI-Facing Providers ---

/// Provider to fetch all products for the current store.
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProducts(); // Fetches all by default
});

/// Provider to fetch a single product by its ID.
final productByIdProvider = FutureProvider.family<Product, int>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getProductById(productId);
});
