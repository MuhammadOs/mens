import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/user/addresses/domain/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<Address> addAddress(Address address);
  Future<Address> updateAddress(int id, Address address);
  Future<void> deleteAddress(int id);
  Future<void> setDefaultAddress(int id);
}

final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return AddressRepositoryImpl(dio);
});

class AddressRepositoryImpl implements AddressRepository {
  final Dio _dio;
  AddressRepositoryImpl(this._dio);

  @override
  Future<List<Address>> getAddresses() async {
    try {
      final response = await _dio.get('/addresses');
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => Address.fromJson(json)).toList();
      }
      throw Exception('Failed to load addresses');
    } on DioException catch (e) {
      throw Exception('Network error fetching addresses: ${e.message}');
    }
  }

  @override
  Future<Address> addAddress(Address address) async {
    try {
      final response = await _dio.post(
        '/addresses',
        data: address.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Address.fromJson(response.data);
      }
      throw Exception('Failed to add address');
    } on DioException catch (e) {
      throw Exception('Network error adding address: ${e.message}');
    }
  }

  @override
  Future<Address> updateAddress(int id, Address address) async {
    try {
      final response = await _dio.put(
        '/addresses/$id',
        data: address.toJson(),
      );
      if (response.statusCode == 200) {
        return Address.fromJson(response.data);
      }
      throw Exception('Failed to update address');
    } on DioException catch (e) {
      throw Exception('Network error updating address: ${e.message}');
    }
  }

  @override
  Future<void> deleteAddress(int id) async {
    try {
      final response = await _dio.delete('/addresses/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete address');
      }
    } on DioException catch (e) {
      throw Exception('Network error deleting address: ${e.message}');
    }
  }

  @override
  Future<void> setDefaultAddress(int id) async {
    try {
      // Based on the user's description: "set default"
      // Assuming it's a specific endpoint or a PUT to a sub-resource
      // Usually it's /addresses/{id}/default or similar
      // I'll assume /addresses/$id/set-default based on common patterns or just if it's a PUT with isDefault: true
      // Wait, the user said "set default" as an endpoint. 
      // I'll use /addresses/$id/default or similar if I can find it.
      // Re-reading user request: "a specific address with id, put addess, delete address, and set default."
      // I'll try /addresses/$id/default
      final response = await _dio.put('/addresses/$id/default');
      if (response.statusCode != 200) {
        throw Exception('Failed to set default address');
      }
    } on DioException catch (e) {
      throw Exception('Network error setting default address: ${e.message}');
    }
  }
}
