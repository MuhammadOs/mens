import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/features/user/conversations/domain/conversation.dart';

abstract class ConversationsRepository {
  Future<List<Conversation>> getAllConversations();
  Future<void> replyToConversation(int conversationId, String content);
}

final conversationsRepositoryProvider = Provider<ConversationsRepository>((
  ref,
) {
  final dio = ref.watch(apiServiceProvider);
  return ConversationsRepositoryImpl(dio);
});

class ConversationsRepositoryImpl implements ConversationsRepository {
  final Dio _dio;
  ConversationsRepositoryImpl(this._dio);

  @override
  Future<List<Conversation>> getAllConversations() async {
    try {
      final response = await _dio.get('/contact/conversations');
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        return data.map((json) => Conversation.fromJson(json)).toList();
      }
      throw Exception('Failed to load conversations');
    } on DioException {
      throw Exception('Network error fetching conversations.');
    }
  }

  @override
  Future<void> replyToConversation(int conversationId, String content) async {
    try {
      final response = await _dio.post(
        '/contact/conversations/$conversationId/reply',
        data: {'content': content},
      );
      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception('Failed to send reply');
      }
    } on DioException {
      throw Exception('Network error sending reply.');
    }
  }
}

final conversationsProvider = FutureProvider<List<Conversation>>((ref) {
  return ref.watch(conversationsRepositoryProvider).getAllConversations();
});
