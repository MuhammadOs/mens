import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/admin_users/data/admin_users_repository.dart';
import 'package:mens/features/user/admin_users/domain/admin_user.dart';

class AdminUsersView extends HookConsumerWidget {
  const AdminUsersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);
    final usersAsync = ref.watch(adminUsersProvider);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.adminUsersTitle,
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: usersAsync.whenOrNull(
              data: (users) => Chip(
                avatar: Icon(
                  FontAwesomeIcons.users,
                  size: 12,
                  color: theme.colorScheme.onPrimary,
                ),
                label: Text(
                  '${users.length}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: theme.colorScheme.primary,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
      body: usersAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
        error: (error, _) => _ErrorState(
          error: error.toString(),
          failedLabel: l10n.adminUsersFailedToLoad,
          retryLabel: l10n.retry,
          onRetry: () => ref.invalidate(adminUsersProvider),
          theme: theme,
        ),
        data: (users) {
          final filtered = searchQuery.value.isEmpty
              ? users
              : users.where((u) {
                  final q = searchQuery.value.toLowerCase();
                  return u.fullName.toLowerCase().contains(q) ||
                      u.email.toLowerCase().contains(q) ||
                      u.role.toLowerCase().contains(q);
                }).toList();

          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: l10n.adminUsersSearch,
                    prefixIcon: Icon(
                      FontAwesomeIcons.magnifyingGlass,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                ),
              ),

              // Role filter chips
              _RoleFilterRow(
                users: users,
                searchQuery: searchQuery.value,
                theme: theme,
              ),

              // List
              Expanded(
                child: filtered.isEmpty
                    ? _EmptyState(
                        isSearching: searchQuery.value.isNotEmpty,
                        emptyLabel: l10n.adminUsersEmpty,
                        emptySearchLabel: l10n.adminUsersEmptySearch,
                        theme: theme,
                      )
                    : RefreshIndicator(
                        onRefresh: () async =>
                            ref.invalidate(adminUsersProvider),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _UserCard(
                            user: filtered[index],
                            theme: theme,
                            verifiedLabel: l10n.adminUsersEmailVerified,
                            unverifiedLabel: l10n.adminUsersEmailUnverified,
                            roleLabel: _roleLabel(filtered[index].role, l10n),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Role count chips row ────────────────────────────────────────────────────

class _RoleFilterRow extends StatelessWidget {
  final List<AdminUser> users;
  final String searchQuery;
  final ThemeData theme;

  const _RoleFilterRow({
    required this.users,
    required this.searchQuery,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final roles = <String, int>{};
    for (final u in users) {
      roles[u.role] = (roles[u.role] ?? 0) + 1;
    }

    if (roles.isEmpty) return const SizedBox.shrink();

    final roleOrder = ['Admin', 'StoreOwner', 'User'];
    final sortedRoles = roleOrder.where(roles.containsKey).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: sortedRoles.map((role) {
          final count = roles[role]!;
          final color = _roleColor(role, theme);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Chip(
              label: Text(
                '$role ($count)',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: color.withValues(alpha: 0.12),
              side: BorderSide(color: color.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── User card ───────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final AdminUser user;
  final ThemeData theme;
  final String verifiedLabel;
  final String unverifiedLabel;
  final String roleLabel;

  const _UserCard({
    required this.user,
    required this.theme,
    required this.verifiedLabel,
    required this.unverifiedLabel,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final roleColor = _roleColor(user.role, theme);
    final initials = _initials(user.firstName, user.lastName);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: roleColor.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + role badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName.isNotEmpty ? user.fullName : user.email,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RoleBadge(
                        role: user.role,
                        label: roleLabel,
                        color: roleColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Email
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.envelope,
                        size: 11,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.65,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Phone (if present)
                  if (user.phoneNumber != null) ...[
                    Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.phone,
                          size: 11,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          user.phoneNumber!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                  ],

                  // Bottom row: ID · email confirmed · join date
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '#${user.id}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(width: 8),
                      _EmailConfirmedChip(
                        confirmed: user.emailConfirmed,
                        verifiedLabel: verifiedLabel,
                        unverifiedLabel: unverifiedLabel,
                        theme: theme,
                      ),
                      const Spacer(),
                      Icon(
                        FontAwesomeIcons.calendarDays,
                        size: 10,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.35,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(user.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Role badge ──────────────────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  final String role;
  final String label;
  final Color color;
  const _RoleBadge({
    required this.role,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Email confirmed chip ────────────────────────────────────────────────────

class _EmailConfirmedChip extends StatelessWidget {
  final bool confirmed;
  final String verifiedLabel;
  final String unverifiedLabel;
  final ThemeData theme;
  const _EmailConfirmedChip({
    required this.confirmed,
    required this.verifiedLabel,
    required this.unverifiedLabel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = confirmed ? Colors.green : theme.colorScheme.error;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          confirmed
              ? FontAwesomeIcons.circleCheck
              : FontAwesomeIcons.circleXmark,
          size: 11,
          color: color,
        ),
        const SizedBox(width: 3),
        Text(
          confirmed ? verifiedLabel : unverifiedLabel,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final String emptyLabel;
  final String emptySearchLabel;
  final ThemeData theme;
  const _EmptyState({
    required this.isSearching,
    required this.emptyLabel,
    required this.emptySearchLabel,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching
                ? FontAwesomeIcons.magnifyingGlass
                : FontAwesomeIcons.users,
            size: 56,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            isSearching ? emptySearchLabel : emptyLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String error;
  final String failedLabel;
  final String retryLabel;
  final VoidCallback onRetry;
  final ThemeData theme;
  const _ErrorState({
    required this.error,
    required this.failedLabel,
    required this.retryLabel,
    required this.onRetry,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.circleExclamation,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              failedLabel,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(FontAwesomeIcons.rotateRight, size: 14),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helpers ─────────────────────────────────────────────────────────────────

Color _roleColor(String role, ThemeData theme) {
  switch (role.toLowerCase()) {
    case 'admin':
      return const Color(0xFFE53935); // bold red
    case 'storeowner':
      return const Color(0xFFE07B00); // amber/orange
    default:
      return const Color(0xFF1E88E5); // clear blue for regular User
  }
}

String _roleLabel(String role, dynamic l10n) {
  switch (role.toLowerCase()) {
    case 'storeowner':
      return l10n.adminUsersRoleStoreOwner as String;
    case 'admin':
      return l10n.adminUsersRoleAdmin as String;
    default:
      return l10n.adminUsersRoleUser as String;
  }
}

String _initials(String first, String last) {
  final f = first.isNotEmpty ? first[0].toUpperCase() : '';
  final l = last.isNotEmpty ? last[0].toUpperCase() : '';
  return '$f$l';
}
