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

  /// Updates the primary image for a product (separate endpoint).
  Future<String> updatePrimaryImage({
    required int productId,
    required XFile primaryImage,
  });

  /// Updates the other (non-primary) images for a product.
  Future<List<String>> updateOtherImages({
    required int productId,
    required List<XFile> newImages,
    required List<String> existingImageUrls,
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
        // For admin, keep the storeName from the product data

        return products;
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
        // For admin, keep the storeName from the product data

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

  /// Updates the primary image for a product (separate endpoint).
  @override
  Future<String> updatePrimaryImage({
    required int productId,
    required XFile primaryImage,
  }) async {
    try {
      print("=== UPDATE PRIMARY IMAGE DEBUG ===");
      print("Product ID: $productId");
      print("Primary image: ${primaryImage.name}");

      // Create multipart file
      final imageFile = await MultipartFile.fromFile(
        primaryImage.path,
        filename: primaryImage.name,
      );

      // Create FormData - send image with isPrimary flag
      final formData = FormData.fromMap({
        'Image': imageFile,
        'IsPrimary': true, // Mark this image as primary
      });

      print("Sending PUT to /products/$productId/primary-image");
      final response = await _dio.put(
        '/products/$productId/primary-image',
        data: formData,
        onSendProgress: (int sent, int total) {
          if (kDebugMode) {
            print(
              'Primary image upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      print("=== PRIMARY IMAGE RESPONSE ===");
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract the URL of the uploaded primary image
        String imageUrl = '';

        if (response.data is Map<String, dynamic>) {
          final dataMap = response.data as Map<String, dynamic>;
          imageUrl =
              dataMap['imageUrl'] as String? ??
              dataMap['data']?['imageUrl'] as String? ??
              dataMap['url'] as String? ??
              '';
        }

        print("✅ Primary image updated successfully! URL: $imageUrl");
        return imageUrl;
      } else {
        throw Exception('Primary image update failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("=== DIO EXCEPTION (PRIMARY IMAGE) ===");
      print("Error: ${e.message}");
      String errorMessage = 'Network error updating primary image.';
      if (e.response != null) {
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
            'Update failed with status: ${e.response!.statusCode}';
      }
      print("❌ Error: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      print("❌ Unexpected error updating primary image: $e");
      throw Exception(
        'An unexpected error occurred while updating primary image.',
      );
    }
  }

  /// Updates the other (non-primary) images for a product.
  @override
  Future<List<String>> updateOtherImages({
    required int productId,
    required List<XFile> newImages,
    required List<String> existingImageUrls,
  }) async {
    try {
      print("=== UPDATE OTHER IMAGES DEBUG ===");
      print("Product ID: $productId");
      print("Number of new images: ${newImages.length}");
      print("Number of existing URLs to keep: ${existingImageUrls.length}");
      print("Total images: ${newImages.length + existingImageUrls.length}");

      List<MultipartFile> imageFiles = [];
      for (var image in newImages) {
        print("Processing new image: ${image.path}");
        imageFiles.add(
          await MultipartFile.fromFile(image.path, filename: image.name),
        );
      }

      // Create FormData with new files and existing URLs to preserve
      // All images sent here have IsPrimary = false (implicitly)
      final Map<String, dynamic> formDataMap = {};

      if (imageFiles.isNotEmpty) {
        formDataMap['Images'] = imageFiles;
      }

      if (existingImageUrls.isNotEmpty) {
        formDataMap['ExistingImageUrls'] = existingImageUrls;
      }

      final formData = FormData.fromMap(formDataMap);

      print("FormData created:");
      print("  - Fields: ${formData.fields.length}");
      print("  - Files: ${formData.files.length}");

      // Send PUT request to the images endpoint
      print("Sending PUT to /products/$productId/images");
      final response = await _dio.put(
        '/products/$productId/images',
        data: formData,
        onSendProgress: (int sent, int total) {
          if (kDebugMode) {
            print(
              'Other images upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      print("=== OTHER IMAGES RESPONSE ===");
      print("Response status: ${response.statusCode}");
      print("Response data: ${response.data}");

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        if (response.statusCode == 204) {
          print("✅ Other images updated successfully! (204 No Content)");
          return [];
        }

        // Extract image URLs from response
        List<String> imageUrls = [];

        if (response.data is Map<String, dynamic>) {
          final dataMap = response.data as Map<String, dynamic>;

          if (dataMap['data']?['imageUrls'] is List) {
            imageUrls = List<String>.from(dataMap['data']['imageUrls']);
          } else if (dataMap['imageUrls'] is List) {
            imageUrls = List<String>.from(dataMap['imageUrls']);
          } else if (dataMap['data'] is List) {
            imageUrls = List<String>.from(dataMap['data']);
          }
        }

        print(
          "✅ Other images updated successfully! Returned ${imageUrls.length} URLs",
        );
        return imageUrls;
      } else {
        throw Exception('Other images update failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print("=== DIO EXCEPTION (OTHER IMAGES) ===");
      print("Error: ${e.message}");
      String errorMessage = 'Network error updating other images.';
      if (e.response != null) {
        final dynamic messageValue = e.response!.data?['message'];
        errorMessage =
            messageValue?.toString() ??
            'Update failed with status: ${e.response!.statusCode}';
      }
      print("❌ Error: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      print("❌ Unexpected error updating other images: $e");
      throw Exception(
        'An unexpected error occurred while updating other images.',
      );
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
