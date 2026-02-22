import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/user/admin_users/domain/admin_user.dart';

abstract class AdminUsersRepository {
  Future<List<AdminUser>> getAllUsers();
}

final adminUsersRepositoryProvider = Provider<AdminUsersRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return AdminUsersRepositoryImpl(dio);
});

class AdminUsersRepositoryImpl implements AdminUsersRepository {
  final Dio _dio;
  AdminUsersRepositoryImpl(this._dio);

  @override
  Future<List<AdminUser>> getAllUsers() async {
    try {
      final response = await _dio.get('/admin/users');
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => AdminUser.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load users');
    } on DioException catch (e) {
      throw Exception('Network error fetching users: ${e.message}');
    }
  }
}

final adminUsersProvider = FutureProvider<List<AdminUser>>((ref) {
  return ref.watch(adminUsersRepositoryProvider).getAllUsers();
});
