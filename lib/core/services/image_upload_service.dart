import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/core/services/api_service.dart';

/// Provider for the ImageUploadService
final imageUploadServiceProvider = Provider<ImageUploadService>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return ImageUploadService(dio);
});

/// Service responsible for uploading images to the server
class ImageUploadService {
  final Dio _dio;

  ImageUploadService(this._dio);

  /// Uploads a single image to the server and returns the image URL
  ///
  /// The endpoint returns: { "imageUrl": "https://..." }
  Future<String> uploadImage(XFile image) async {
    try {
      // Create multipart file from XFile
      final imageFile = await MultipartFile.fromFile(
        image.path,
        filename: image.name,
      );

      // Create FormData with the image (API expects 'file' as the field name)
      final formData = FormData.fromMap({'file': imageFile});

      if (kDebugMode) {
        print('=== IMAGE UPLOAD DEBUG ===');
        print('Uploading image: ${image.name}');
        print('Image path: ${image.path}');
        print('Endpoint: POST /images/upload');
      }

      // Send POST request to upload endpoint
      final response = await _dio.post(
        '/images/upload',
        data: formData,
        onSendProgress: (int sent, int total) {
          if (kDebugMode) {
            print(
              'Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
            );
          }
        },
      );

      if (kDebugMode) {
        print('=== IMAGE UPLOAD RESPONSE ===');
        print('Status code: ${response.statusCode}');
        print('Response data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract imageUrl from response
        final imageUrl = response.data['imageUrl'] as String?;

        if (imageUrl == null || imageUrl.isEmpty) {
          throw Exception('Server did not return a valid image URL');
        }

        if (kDebugMode) {
          print('✅ Image uploaded successfully: $imageUrl');
        }

        return imageUrl;
      } else {
        throw Exception('Image upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (kDebugMode) {
        print('=== IMAGE UPLOAD ERROR ===');
        print('Error type: ${e.type}');
        print('Error message: ${e.message}');
        print('Status code: ${e.response?.statusCode}');
        print('Response data: ${e.response?.data}');
        print('Request path: ${e.requestOptions.path}');
        print('Request method: ${e.requestOptions.method}');
      }
      String errorMessage = 'Network error uploading image.';
      if (e.response != null) {
        final dynamic messageValue = e.response!.data?['message'];
        final dynamic errors = e.response!.data?['errors'];
        errorMessage =
            messageValue?.toString() ??
            errors?.toString() ??
            'Upload failed with status: ${e.response!.statusCode}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error uploading image: $e');
      }
      throw Exception('An unexpected error occurred while uploading image.');
    }
  }

  /// Uploads multiple images and returns a list of image URLs
  Future<List<String>> uploadImages(List<XFile> images) async {
    final List<String> imageUrls = [];

    for (final image in images) {
      final imageUrl = await uploadImage(image);
      imageUrls.add(imageUrl);
    }

    return imageUrls;
  }
}
