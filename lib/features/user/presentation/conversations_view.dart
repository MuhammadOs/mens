import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/conversations/data/conversations_repository.dart';
import 'package:mens/features/user/conversations/domain/conversation.dart';
import 'package:mens/features/user/conversations/presentation/notifiers/reply_notifier.dart';
import 'package:mens/features/user/presentation/user_drawer.dart';

class ConversationsView extends HookConsumerWidget {
  const ConversationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);
    final conversationsAsync = ref.watch(conversationsProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final selectedConversation = useState<Conversation?>(null);

    // Listen to search changes
    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      //drawer: const UserDrawer(),
      appBar: AppBar(
        title: Text(
          l10n.userConversations,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          // Filter conversations based on search query
          final filteredConversations = searchQuery.value.isEmpty
              ? conversations
              : conversations.where((conv) {
                  final query = searchQuery.value.toLowerCase();
                  return conv.userName.toLowerCase().contains(query) ||
                      conv.messages.any(
                        (msg) => msg.content.toLowerCase().contains(query),
                      );
                }).toList();

          if (filteredConversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    searchQuery.value.isEmpty
                        ? Icons.chat_bubble_outline
                        : Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchQuery.value.isEmpty
                        ? l10n.noConversationsYet
                        : l10n.noConversationsFound,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return Row(
            children: [
              // Conversations List
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: l10n.searchConversations,
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    // Conversations List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(conversationsProvider);
                        },
                        child: ListView.builder(
                          itemCount: filteredConversations.length,
                          itemBuilder: (context, index) {
                            final conversation = filteredConversations[index];
                            final isSelected =
                                selectedConversation.value?.id ==
                                conversation.id;
                            final lastMessage = conversation.messages.isNotEmpty
                                ? conversation.messages.last
                                : null;

                            return ConversationListItem(
                              conversation: conversation,
                              lastMessage: lastMessage,
                              isSelected: isSelected,
                              onTap: () {
                                selectedConversation.value = conversation;
                              },
                              theme: theme,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              VerticalDivider(
                width: 1,
                color: theme.colorScheme.outlineVariant,
              ),

              // Conversation Detail
              Expanded(
                flex: 3,
                child: selectedConversation.value == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat,
                              size: 64,
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Select a conversation to view messages',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ConversationDetailView(
                        key: ValueKey(selectedConversation.value!.id),
                        conversation: selectedConversation.value!,
                        theme: theme,
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: SizedBox.shrink()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading conversations',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(conversationsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final ConversationMessage? lastMessage;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const ConversationListItem({
    super.key,
    required this.conversation,
    required this.lastMessage,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withOpacity(0.5)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Text(
                  conversation.userName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            conversation.userName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFormat.format(conversation.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (lastMessage != null) ...[
                      Text(
                        lastMessage!.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            timeFormat.format(lastMessage!.sentAt),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.4,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${conversation.messages.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConversationDetailView extends HookConsumerWidget {
  final Conversation conversation;
  final ThemeData theme;

  const ConversationDetailView({
    super.key,
    required this.conversation,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');
    final replyController = useTextEditingController();
    final scrollController = useScrollController();
    final replyState = ref.watch(replyNotifierProvider);
    final replyNotifier = ref.read(replyNotifierProvider.notifier);
    final canSend = useState(false);

    // Watch the conversations to get the latest data
    final conversationsAsync = ref.watch(conversationsProvider);

    // Listen to text changes to enable/disable send button
    useEffect(() {
      void listener() {
        canSend.value = replyController.text.trim().isNotEmpty;
      }

      replyController.addListener(listener);
      return () => replyController.removeListener(listener);
    }, [replyController]);

    // Get the updated conversation from the latest data
    final currentConversation = conversationsAsync.maybeWhen(
      data: (conversations) {
        return conversations.firstWhere(
          (conv) => conv.id == conversation.id,
          orElse: () => conversation,
        );
      },
      orElse: () => conversation,
    );

    // Auto-scroll to bottom when messages change
    useEffect(() {
      if (scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
      return null;
    }, [currentConversation.messages.length]);

    // Listen for reply status
    ref.listen(replyNotifierProvider, (previous, next) {
      if (previous is AsyncLoading && next is AsyncData) {
        // SnackBar removed: replySentSuccess notification suppressed.
        replyController.clear();
      } else if (next is AsyncError) {
        // SnackBar removed: errorSendingReply notification suppressed.
      }
    });

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  currentConversation.userName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentConversation.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'User ID: ${currentConversation.userId}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16.0),
            itemCount: currentConversation.messages.length,
            itemBuilder: (context, index) {
              final message = currentConversation.messages[index];
              return MessageBubble(
                message: message,
                dateFormat: dateFormat,
                theme: theme,
              );
            },
          ),
        ),

        // Reply Input
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: replyController,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: replyState.isLoading || !canSend.value
                    ? null
                    : () {
                        final content = replyController.text.trim();
                        if (content.isNotEmpty) {
                          replyNotifier.sendReply(
                            currentConversation.id,
                            content,
                          );
                        }
                      },
                icon: replyState.isLoading
                    ? SizedBox.shrink()
                    : const Icon(Icons.send),
                tooltip: 'Send Reply',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ConversationMessage message;
  final DateFormat dateFormat;
  final ThemeData theme;

  const MessageBubble({
    super.key,
    required this.message,
    required this.dateFormat,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isFromUser = message.isFromUser;

    return Align(
      alignment: isFromUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
        ),
        child: Column(
          crossAxisAlignment: isFromUser
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFromUser
                    ? theme.colorScheme.surfaceContainerHigh
                    : theme.colorScheme.primary.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isFromUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                  bottomRight: isFromUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                ),
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isFromUser
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                dateFormat.format(message.sentAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
