import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/seller/contact_us/domain/message.dart';

abstract class ContactUsRepository {
  Future<List<Message>> getMessages();
  Future<void> sendMessage(String content);
}

final contactUsRepositoryProvider = Provider<ContactUsRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return ContactUsRepositoryImpl(dio);
});

class ContactUsRepositoryImpl implements ContactUsRepository {
  final Dio _dio;
  ContactUsRepositoryImpl(this._dio);

  @override
  Future<List<Message>> getMessages() async {
    try {
      final response = await _dio.get('/contact/messages');
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((json) => Message.fromJson(json)).toList();
      }
      throw Exception('Failed to load messages');
    } on DioException {
      throw Exception('Network error fetching messages.');
    }
  }

  @override
  Future<void> sendMessage(String content) async {
    try {
      final response = await _dio.post(
        '/contact/messages',
        data: {'content': content},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send message');
      }
    } on DioException {
      throw Exception('Network error sending message.');
    }
  }
}

// UI-facing provider to fetch the list of messages
final messagesProvider = FutureProvider<List<Message>>((ref) async {
  final repository = ref.watch(contactUsRepositoryProvider);
  return repository.getMessages();
});