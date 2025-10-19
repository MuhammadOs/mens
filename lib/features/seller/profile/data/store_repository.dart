import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/seller/profile/notifiers/shop_info_notifier.dart'; // Provides ShopInfoData

// Interface
abstract class ShopRepository {
  Future<ShopInfoData> updateShopInfo(int storeId, ShopInfoData data);
  Future<String> updateStoreImage(int storeId, XFile imageFile);
}

// Provider
final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return ShopRepositoryImpl(dio);
});

// Implementation
class ShopRepositoryImpl implements ShopRepository {
  final Dio _dio;
  ShopRepositoryImpl(this._dio);

  @override
  Future<ShopInfoData> updateShopInfo(int storeId, ShopInfoData data) async {
    try {
      final response = await _dio.put(
        '/stores/$storeId', // Use PUT request
        data: {
          'brandName': data.shopName,
          'brandDescription': data.description,
          'vat': data.vatNumber,
          'categoryId': data.categoryId,
          'location': data.location,
        },
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        final responseData = response.data['data'];
        return data; // Assuming success means the sent data is now the current data
      } else {
        throw Exception(
          'Failed to update shop info: ${response.data?['message'] ?? 'Unknown error'}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error updating shop info.';
      if (e.response != null) {
        errorMessage =
            e.response!.data?['message'] ??
            'Update failed with status: ${e.response!.statusCode}';
      }
      print("DioException updating shop info: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      print("Unexpected error updating shop info: $e");
      throw Exception('An unexpected error occurred.');
    }
  }

  @override
  Future<String> updateStoreImage(int storeId, XFile imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });
      final response = await _dio.put(
        '/stores/$storeId/image', // Endpoint remains the same
        data: formData,
        onSendProgress: (int sent, int total) {
          // Optional progress
          print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );
      if (response.statusCode == 200 && response.data['token'] != null) {
        return response.data['token']; // Return the image URL
      } else {
        throw Exception(
          'Failed to upload image: ${response.data?['message'] ?? 'Status code ${response.statusCode}'}',
        );
      }
    } on DioException catch (e) {
      String errorMessage = 'Network error uploading image.';
      if (e.response != null) {
        errorMessage =
            e.response!.data?['message'] ??
            'Upload failed with status: ${e.response!.statusCode}';
      }
      print("DioException uploading image: $errorMessage");
      throw Exception(errorMessage);
    } catch (e) {
      print("Unexpected error uploading image: $e");
      throw Exception('An unexpected error occurred during image upload.');
    }
  }
}
