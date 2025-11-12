import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier for loading counter
class LoadingNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() {
    state++;
  }

  void decrement() {
    if (state > 0) {
      state--;
    }
  }
}

final loadingNotifierProvider = NotifierProvider<LoadingNotifier, int>(
  LoadingNotifier.new,
);

// Computed provider for isLoading
final isLoadingProvider = Provider<bool>((ref) {
  final counter = ref.watch(loadingNotifierProvider);
  return counter > 0;
});