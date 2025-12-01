import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/user/conversations/data/conversations_repository.dart';

final replyNotifierProvider = NotifierProvider<ReplyNotifier, AsyncValue<void>>(
  ReplyNotifier.new,
);

class ReplyNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null); // Initial idle state

  Future<void> sendReply(int conversationId, String content) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(conversationsRepositoryProvider);
      await repository.replyToConversation(conversationId, content);
      state = const AsyncValue.data(null);
      // Invalidate conversations to refresh the list
      ref.invalidate(conversationsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
