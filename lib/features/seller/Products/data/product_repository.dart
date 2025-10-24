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
        // Handle both string and non-string message types
        final dynamic messageValue = response.data?['message'];
        final serverMessage =
            messageValue?.toString() ??
            'Failed to add product: ${response.statusCode}';
        throw Exception(serverMessage);
      }

      print("Product added successfully!");
    } on DioException catch (e) {
      String errorMessage = 'Network error adding product.';
      if (e.response != null) {
        // Handle both string and non-string message types
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
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
        // Handle both string and non-string message types
        final dynamic messageValue = response.data?['message'];
        final serverMessage =
            messageValue?.toString() ?? 'Update failed: ${response.statusCode}';
        throw Exception(serverMessage);
      }
      print("Product details updated successfully!");
    } on DioException catch (e) {
      String errorMessage = 'Network error updating product details.';
      if (e.response != null) {
        // Handle both string and non-string message types
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
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
      print("=== UPDATE PRODUCT IMAGES DEBUG ===");
      print("Product ID: $productId (type: ${productId.runtimeType})");
      print("Number of images: ${images.length}");
      print(
        "Primary image index: $primaryImageIndex (type: ${primaryImageIndex.runtimeType})",
      );
      print("Image alt texts: $imageAltTexts");

      List<MultipartFile> imageFiles = [];
      for (var image in images) {
        print("Processing image: ${image.path}");
        imageFiles.add(
          await MultipartFile.fromFile(image.path, filename: image.name),
        );
      }

      // Create FormData, keys must match API
      final formData = FormData.fromMap({
        'Images': imageFiles,
        'PrimaryImageIndex': primaryImageIndex, // Ensure this is an int
        // 'ImageAltTexts': imageAltTexts ?? [], // Include if API needs it
      });

      print("FormData created with ${formData.fields.length} fields");
      print("FormData fields: ${formData.fields}");
      print("FormData files: ${formData.files.length}");

      // Send PUT request to the specific image endpoint (405 error indicates POST is not allowed)
      print("Sending PUT to /products/$productId/images");
      final response = await _dio.put(
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

      // Debug: Print the full response to understand the structure
      print("=== RESPONSE RECEIVED ===");
      print("Response status: ${response.statusCode}");
      print("Response data type: ${response.data.runtimeType}");
      print("Response data: ${response.data}");

      // Check for successful status codes (200, 201, 204)
      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        // 204 No Content - success but no body returned
        if (response.statusCode == 204) {
          print("✅ Product images updated successfully! (204 No Content)");
          return []; // Return empty list since no URLs are returned
        }

        // Try to extract image URLs from various possible response structures
        List<String> newUrls = [];

        if (response.data is Map<String, dynamic>) {
          final dataMap = response.data as Map<String, dynamic>;

          if (dataMap['data']?['imageUrls'] is List) {
            newUrls = List<String>.from(dataMap['data']['imageUrls']);
            print("Extracted URLs from data.imageUrls: $newUrls");
          } else if (dataMap['imageUrls'] is List) {
            newUrls = List<String>.from(dataMap['imageUrls']);
            print("Extracted URLs from imageUrls: $newUrls");
          } else if (dataMap['data'] is List) {
            newUrls = List<String>.from(dataMap['data']);
            print("Extracted URLs from data: $newUrls");
          } else {
            print("⚠️ Could not find image URLs in response structure");
          }
        } else {
          print("⚠️ Response data is not a Map, cannot extract image URLs");
        }

        print(
          "✅ Product images updated successfully! Returned ${newUrls.length} URLs",
        );
        return newUrls; // Return the new URLs
      } else {
        // Handle error responses
        String serverMessage = 'Image update failed: ${response.statusCode}';

        if (response.data is Map<String, dynamic>) {
          final dynamic messageValue =
              (response.data as Map<String, dynamic>)['message'];
          if (messageValue != null) {
            serverMessage = messageValue.toString();
          }
        }

        print("❌ Server error: $serverMessage");
        throw Exception(serverMessage);
      }
    } on DioException catch (e) {
      print("=== DIO EXCEPTION ===");
      print("Type: ${e.type}");
      print("Message: ${e.message}");

      String errorMessage = 'Network error updating images.';
      if (e.response != null) {
        print("Response status: ${e.response!.statusCode}");
        print("Response data type: ${e.response!.data.runtimeType}");
        print("Response data: ${e.response!.data}");

        // Handle different response data types safely
        if (e.response!.data is Map<String, dynamic>) {
          final responseMap = e.response!.data as Map<String, dynamic>;

          // Try to get error message
          final dynamic messageValue = responseMap['message'];

          // Check for validation errors
          if (responseMap['errors'] != null) {
            print("Validation errors: ${responseMap['errors']}");
            errorMessage =
                "Validation error: ${responseMap['errors'].toString()}";
          } else if (messageValue != null) {
            errorMessage = messageValue.toString();
          } else {
            errorMessage =
                'Update failed with status: ${e.response!.statusCode}';
          }
        } else if (e.response!.data is String &&
            e.response!.data.toString().isNotEmpty) {
          errorMessage = e.response!.data.toString();
        } else {
          // Empty response or unknown type - provide helpful message based on status code
          if (e.response!.statusCode == 405) {
            errorMessage =
                'Method not allowed (405). The API does not support this request method.';
          } else {
            errorMessage =
                'Update failed with status: ${e.response!.statusCode}';
          }
        }
      } else {
        print("No response received. Error: ${e.error}");
      }

      print("❌ Final error message: $errorMessage");
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      print("=== UNEXPECTED ERROR ===");
      print("Error type: ${e.runtimeType}");
      print("Error: $e");
      print("Stack trace: $stackTrace");
      throw Exception('An unexpected error occurred while updating images: $e');
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
        // Handle both string and non-string message types
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
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
