import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // For XFile in add/update methods
import 'package:mens/core/services/api_service.dart'; // Provides apiServiceProvider (adjust path if needed)
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/features/seller/Products/domain/product.dart'; // Provides Product model (adjust path if needed)
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
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
    required List<XFile> images,
    List<String>? imageAltTexts,
    int primaryImageIndex = 0,
  });

  /// Updates the text details of an existing product.
  Future<void> updateProductDetails({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
  });

  /// Updates the images associated with an existing product.
  Future<List<String>> updateProductImages({
    required int productId,
    required List<XFile> images,
    int primaryImageIndex = 0,
    List<String>? imageAltTexts,
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
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load products: Invalid response structure or missing "items" key.',
        );
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeout, status codes)
      print("Error fetching products: ${e.message}");
      throw Exception('Failed to load products due to network error.');
    } catch (e) {
      // Handle potential JSON parsing errors or other unexpected issues
      print("Error parsing products: $e");
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
        return PaginatedResponse.fromJsonTyped<Product>(
          responseData,
          Product.fromJson,
        );
      } else {
        throw Exception('Failed to load products: Invalid response structure.');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors (network, timeout, status codes)
      print("Error fetching paginated products: ${e.message}");
      throw Exception('Failed to load products due to network error.');
    } catch (e) {
      // Handle potential JSON parsing errors or other unexpected issues
      print("Error parsing paginated products: $e");
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
    } on DioException catch (e) {
      print("Error fetching product $productId: ${e.message}");
      throw Exception('Failed to load product details.');
    } catch (e) {
      print("Error parsing product $productId: $e");
      throw Exception('Failed to parse product details.');
    }
  }

  /// Adds a new product using multipart/form-data.
  @override
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
    required List<XFile> images,
    List<String>? imageAltTexts, // Optional
    int primaryImageIndex = 0, // Default to first image
  }) async {
    // Get storeId if required by the /products endpoint (might be inferred from auth token)
    // final userProfile = _ref.read(authNotifierProvider).asData?.value;
    // final storeId = userProfile?.store?.id;
    // if (storeId == null) throw Exception('Store ID not found.');

    try {
      // Prepare image files as MultipartFile list
      List<MultipartFile> imageFiles = [];
      for (var image in images) {
        imageFiles.add(
          await MultipartFile.fromFile(image.path, filename: image.name),
        );
      }

      // Create FormData, ensuring keys match the API ('Name', 'Description', etc.)
      final formData = FormData.fromMap({
        'Name': name,
        'Description': description,
        'Price': price,
        'StockQuantity': stockQuantity,
        'SubCategoryId': subCategoryId,
        'Images': imageFiles, // Pass the list of MultipartFile
        // Include these if your API requires them:
        // 'ImageAltTexts': imageAltTexts ?? [],
        // 'PrimaryImageIndex': primaryImageIndex,
        // 'StoreId': storeId, // If needed in form data
      });

      // Send POST request to the /products endpoint
      final response = await _dio.post(
        '/products',
        data: formData,
        onSendProgress: (int sent, int total) {
          // Optional progress tracking
          if (kDebugMode) {
            print(
              'Add product upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      // Check for successful status codes
      if (response.statusCode != 200 && response.statusCode != 201) {
        final serverMessage =
            response.data?['message'] ??
            'Failed to add product: ${response.statusCode}';
        throw Exception(serverMessage);
      }

      print("Product added successfully!");
    } on DioException catch (e) {
      String errorMessage = 'Network error adding product.';
      if (e.response != null) {
        errorMessage =
            e.response!.data?['message'] ??
            (e.response!.data?['errors']?.toString() ??
                'Failed with status: ${e.response!.statusCode}');
      }
      print("DioException adding product: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      print("Unexpected error adding product: $e");
      throw Exception('An unexpected error occurred while adding the product.');
    }
  }

  /// Updates the text details of an existing product (uses PUT).
  @override
  Future<void> updateProductDetails({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stockQuantity,
    required int subCategoryId,
  }) async {
    try {
      final response = await _dio.patch(
        // Use PUT (or PATCH if API supports partial updates)
        '/products/$productId',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'stockQuantity': stockQuantity,
          'subCategoryId': subCategoryId,
        },
      );
      if (response.statusCode != 200) {
        // Check for success (e.g., 200 OK, 204 No Content)
        final serverMessage =
            response.data?['message'] ??
            'Update failed: ${response.statusCode}';
        throw Exception(serverMessage);
      }
      print("Product details updated successfully!");
    } on DioException catch (e) {
      String errorMessage = 'Network error updating product details.';
      if (e.response != null) {
        errorMessage =
            e.response!.data?['message'] ??
            (e.response!.data?['errors']?.toString() ??
                'Update failed with status: ${e.response!.statusCode}');
      }
      print("DioException updating product details: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      print("Unexpected error updating product details: $e");
      throw Exception('An unexpected error occurred while updating details.');
    }
  }

  /// Updates the images for an existing product (uses POST).
  @override
  Future<List<String>> updateProductImages({
    required int productId,
    required List<XFile> images, // Only new images to upload
    int primaryImageIndex = 0,
    List<String>? imageAltTexts, // Optional
  }) async {
    try {
      List<MultipartFile> imageFiles = [];
      for (var image in images) {
        imageFiles.add(
          await MultipartFile.fromFile(image.path, filename: image.name),
        );
      }

      // Create FormData, keys must match API
      final formData = FormData.fromMap({
        'Images': imageFiles,
        'PrimaryImageIndex': primaryImageIndex,
        // 'ImageAltTexts': imageAltTexts ?? [], // Include if API needs it
      });

      // Send POST request to the specific image endpoint
      // (Check if API uses PUT or POST for image updates)
      final response = await _dio.post(
        '/products/$productId/images',
        data: formData,
        onSendProgress: (int sent, int total) {
          if (kDebugMode) {
            print(
              'Image update progress: ${(sent / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      // Assuming the response contains the new list of image URLs
      if (response.statusCode == 200 &&
          response.data?['data']?['imageUrls'] is List) {
        List<String> newUrls = List<String>.from(
          response.data!['data']['imageUrls'],
        );
        print("Product images updated successfully!");
        return newUrls; // Return the new URLs
      } else {
        final serverMessage =
            response.data?['message'] ??
            'Image update failed: ${response.statusCode}';
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error updating images.';
      if (e.response != null) {
        errorMessage =
            e.response!.data?['message'] ??
            'Update failed with status: ${e.response!.statusCode}';
      }
      print("DioException updating images: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      print("Unexpected error updating images: $e");
      throw Exception('An unexpected error occurred while updating images.');
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
      print("Product $productId deleted successfully.");
    } on DioException catch (e) {
      String errorMessage = 'Network error deleting product.';
      if (e.response != null) {
        errorMessage =
            e.response!.data?['message'] ??
            'Delete failed: ${e.response!.statusCode}';
      }
      print("DioException deleting product: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      print("Unexpected error deleting product: $e");
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
