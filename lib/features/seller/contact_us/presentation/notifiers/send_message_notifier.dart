import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/features/seller/contact_us/data/contact_us_repository.dart';

final sendMessageNotifierProvider = NotifierProvider<SendMessageNotifier, AsyncValue<void>>(
  SendMessageNotifier.new,
);

class SendMessageNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null); // Initial idle state

  Future<void> sendMessage(String content) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(contactUsRepositoryProvider);
      await repository.sendMessage(content);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}