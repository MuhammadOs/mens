import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/admin/conversations/data/conversations_repository.dart';
import 'package:mens/features/admin/conversations/domain/conversation.dart';
import 'package:mens/features/admin/presentation/admin_drawer.dart';

class ConversationsView extends HookConsumerWidget {
  const ConversationsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text("User Conversations"),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go(AppRoutes.adminProducts);
            },
            icon: const Icon(Icons.inventory_2),
            label: const Text("Products"),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              context.go(AppRoutes.adminBrands);
            },
            icon: const Icon(Icons.store),
            label: const Text("Brands"),
          ),
        ],
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
                        ? 'No conversations yet'
                        : 'No conversations found',
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
                          hintText: 'Search conversations...',
                          prefixIcon: const Icon(Icons.search),
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
                        conversation: selectedConversation.value!,
                        theme: theme,
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant,
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
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  conversation.userName.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
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
                              fontWeight: FontWeight.bold,
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
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (lastMessage != null) ...[
                      Text(
                        lastMessage!.content,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
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
                                0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${conversation.messages.length}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
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

class ConversationDetailView extends StatelessWidget {
  final Conversation conversation;
  final ThemeData theme;

  const ConversationDetailView({
    super.key,
    required this.conversation,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

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
                  conversation.userName.substring(0, 1).toUpperCase(),
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
                      conversation.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'User ID: ${conversation.userId}',
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
            padding: const EdgeInsets.all(16.0),
            itemCount: conversation.messages.length,
            itemBuilder: (context, index) {
              final message = conversation.messages[index];
              return MessageBubble(
                message: message,
                dateFormat: dateFormat,
                theme: theme,
              );
            },
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
                    ? theme.colorScheme.surfaceContainerHighest
                    : theme.colorScheme.primaryContainer,
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
                      : theme.colorScheme.onPrimaryContainer,
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
