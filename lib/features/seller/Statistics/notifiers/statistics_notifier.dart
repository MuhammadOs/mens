import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/seller/Statistics/data/statistics_model.dart';

final statisticsProvider = FutureProvider.family<StatisticsResponse, int?>((
  ref,
  storeId,
) async {
  // If storeId is null, throw error
  if (storeId == null) {
    throw Exception(
      'Store ID is not available. Please ensure you are logged in as a seller.',
    );
  }

  try {
    // ignore: avoid_print
    print('Fetching statistics for storeId: $storeId');

    // Get the configured Dio instance with auth interceptor
    final dio = ref.read(apiServiceProvider);

    // Make the request using Dio (includes auth token via interceptor)
    final response = await dio.get('/stores/$storeId/statistics');

    // ignore: avoid_print
    print('Statistics API response status: ${response.statusCode}');
    // ignore: avoid_print
    print('Statistics API response data: ${response.data}');

    // Dio automatically throws DioException on non-2xx status codes
    return StatisticsResponse.fromJson(response.data);
  } on DioException catch (e) {
    // ignore: avoid_print
    print('DioException fetching statistics: ${e.message}');
    if (e.response != null) {
      // ignore: avoid_print
      print('Error response: ${e.response?.statusCode} - ${e.response?.data}');
      throw Exception(
        'Failed to load statistics (${e.response?.statusCode}): ${e.response?.data}',
      );
    }
    throw Exception('Error fetching statistics: ${e.message}');
  } catch (e) {
    // ignore: avoid_print
    print('Error fetching statistics: $e');
    throw Exception('Error fetching statistics: $e');
  }
});
