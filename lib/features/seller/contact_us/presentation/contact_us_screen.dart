import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/seller/contact_us/data/contact_us_repository.dart';
import 'package:mens/features/seller/contact_us/domain/message.dart';
import 'package:mens/features/seller/contact_us/presentation/notifiers/send_message_notifier.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ContactUsScreen extends HookConsumerWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final messagesAsync = ref.watch(messagesProvider);
    final sendMessageState = ref.watch(sendMessageNotifierProvider);
    final sendMessageNotifier = ref.read(sendMessageNotifierProvider.notifier);
    final textController = useTextEditingController();

    // Listen for send message results
    ref.listen(sendMessageNotifierProvider, (previous, next) {
      if (previous is AsyncLoading && next is AsyncData) {
        textController.clear(); // Clear text field on success
        ref.invalidate(messagesProvider); // Refresh the message list
        // SnackBar removed: messageSentSuccess notification suppressed.
      } else if (next is AsyncError) {
        // SnackBar removed: errorSendingMessage notification suppressed.
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.contactUsTitle)),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(messagesProvider);
                await ref.read(messagesProvider.future);
              },
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return _ScrollableEmptyState(
                      icon: Icons.chat_bubble_outline,
                      message: l10n.noMessagesYet,
                    );
                  }

                  // ✅ SORT MESSAGES: Oldest first (chronological order)
                  messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

                  return ListView.builder(
                    // ✅ REVERSED REMOVED: Now scrolls normally from top to bottom
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: messages[index]),
                  );
                },
                loading: () => Skeletonizer(
                  // Loading State
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Align(
                          alignment: index.isEven
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Bone(
                            height: 60,
                            width: 250,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                error: (e, st) => _ScrollableErrorState(
                  // Error State
                  error: e.toString(),
                  onRefresh: () => ref.invalidate(messagesProvider),
                ),
              ),
            ),
          ),
          _MessageInputField(
            controller: textController,
            isLoading: sendMessageState.isLoading,
            onSend: () {
              if (textController.text.trim().isNotEmpty) {
                sendMessageNotifier.sendMessage(textController.text.trim());
              }
            },
          ),
        ],
      ),
    );
  }
}

// --- Helper Widgets ---

// Input Field (Unchanged, but solid)
class _MessageInputField extends HookConsumerWidget {
  const _MessageInputField({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final canSend = useState(false);

    useEffect(() {
      void listener() => canSend.value = controller.text.trim().isNotEmpty;
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: l10n.typeYourMessage,
                border: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
              minLines: 1,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(width: 24, height: 24),
                )
              : IconButton(
                  icon: Icon(Icons.send),
                  color: canSend.value
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                  onPressed: canSend.value ? onSend : null,
                ),
        ],
      ),
    );
  }
}

// Message Bubble (Enhanced with Timestamp)
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final Message message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMe = message.isSentByStoreOwner;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isMe ? theme.colorScheme.primary : theme.colorScheme.surface;
    final textColor = isMe
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content, style: TextStyle(color: textColor)),
            const SizedBox(height: 4),
            Text(
              DateFormat(
                'MMM d, h:mm a',
              ).format(message.createdAt.toLocal()), // Format timestamp
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Empty State Widget (Scrollable)
class _ScrollableEmptyState extends StatelessWidget {
  const _ScrollableEmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 64,
                      color: theme.hintColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Reusable Error State Widget (Scrollable)
class _ScrollableErrorState extends ConsumerWidget {
  const _ScrollableErrorState({required this.error, required this.onRefresh});
  final String error;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider); // For "Pull to refresh" text

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Error: $error", // TODO: Localize
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pullDownToRefresh, // TODO: Localize
                      style: TextStyle(color: theme.hintColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
