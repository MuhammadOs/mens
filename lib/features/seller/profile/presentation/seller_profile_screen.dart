import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';

class SellerProfileScreen extends ConsumerWidget {
  const SellerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final authState = ref.watch(authNotifierProvider);
    final userProfile = authState.asData?.value;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero header ──────────────────────────────────────────────
          _ProfileSliverAppBar(userProfile: userProfile),

          // ── Body ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                const SizedBox(height: 20),
                _StatsRow(userProfile: userProfile),
                const SizedBox(height: 20),

                // Info section
                _SectionHeader(title: 'Contact Information'),
                const SizedBox(height: 10),
                _InfoCard(userProfile: userProfile),
                const SizedBox(height: 20),

                // Actions section
                _SectionHeader(title: l10n.editProfile),
                const SizedBox(height: 10),
                _ActionsCard(l10n: l10n),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Sliver App Bar / Hero header ─────────────────────────────────────────────

class _ProfileSliverAppBar extends StatelessWidget {
  final dynamic userProfile;
  const _ProfileSliverAppBar({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final brandImageUrl = userProfile?.store?.brandImage as String?;
    final brandName = (userProfile?.store?.brandName as String?) ?? 'Brand';
    final ownerName = (userProfile?.fullName as String?) ?? '';
    final email = (userProfile?.email as String?) ?? '';
    final phone = (userProfile?.phoneNumber as String?) ?? '';
    final initials = brandName.isNotEmpty ? brandName[0].toUpperCase() : 'B';
    final hasImage = brandImageUrl != null && brandImageUrl.isNotEmpty;

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: cs.secondary,
      foregroundColor: cs.onPrimary,
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.chevronLeft, size: 18, color: cs.onPrimary),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            FontAwesomeIcons.penToSquare,
            size: 16,
            color: cs.onPrimary,
          ),
          tooltip: 'Edit Profile',
          onPressed: () => context.push(AppRoutes.editProfile),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.secondary,
                    cs.secondary.withValues(alpha: 0.82),
                    cs.primary.withValues(alpha: 0.65),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: _DecorCircle(
                size: 140,
                opacity: 0.10,
                color: cs.onPrimary,
              ),
            ),
            Positioned(
              top: 60,
              right: 60,
              child: _DecorCircle(size: 60, opacity: 0.07, color: cs.onPrimary),
            ),
            Positioned(
              bottom: 40,
              left: -30,
              child: _DecorCircle(
                size: 100,
                opacity: 0.08,
                color: cs.onPrimary,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 80, 0, 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Avatar
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.35),
                            width: 3,
                          ),
                        ),
                      ),
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: cs.onPrimary.withValues(alpha: 0.18),
                          border: Border.all(color: cs.primary, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withValues(alpha: 0.30),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                          image: hasImage
                              ? DecorationImage(
                                  image: NetworkImage(brandImageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: !hasImage
                            ? Center(
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: cs.onPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 32,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Brand name
                  Text(
                    brandName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: cs.onPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (ownerName.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      ownerName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onPrimary.withValues(alpha: 0.75),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      if (email.isNotEmpty)
                        _InfoChip(
                          icon: FontAwesomeIcons.envelope,
                          label: email,
                          color: cs.onPrimary,
                        ),
                      if (phone.isNotEmpty)
                        _InfoChip(
                          icon: FontAwesomeIcons.phone,
                          label: phone,
                          color: cs.onPrimary,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color.withValues(alpha: 0.80)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.90),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final dynamic userProfile;
  const _StatsRow({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final storeId = (userProfile?.store?.id as int?)?.toString() ?? '—';
    final categoryId =
        (userProfile?.store?.categoryId as int?)?.toString() ?? '—';
    final createdAt = userProfile?.createdAt as DateTime?;
    final year = createdAt != null ? createdAt.year.toString() : '—';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cs.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _StatItem(label: 'Store ID', value: '#$storeId', color: cs.primary),
          _StatDivider(),
          _StatItem(
            label: 'Category',
            value: categoryId,
            color: const Color(0xFF26A69A),
          ),
          _StatDivider(),
          _StatItem(
            label: 'Member Since',
            value: year,
            color: const Color(0xFF5C6BC0),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
    );
  }
}

// ─── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.50),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}

// ─── Info card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final dynamic userProfile;
  const _InfoCard({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final email = (userProfile?.email as String?) ?? '—';
    final phone = (userProfile?.phoneNumber as String?) ?? '—';
    final location = (userProfile?.store?.location as String?) ?? '—';

    final items = [
      _InfoItemData(
        icon: FontAwesomeIcons.envelope,
        label: 'Email',
        value: email,
        color: const Color(0xFF5C6BC0),
      ),
      _InfoItemData(
        icon: FontAwesomeIcons.phone,
        label: 'Phone',
        value: phone,
        color: const Color(0xFF26A69A),
      ),
      _InfoItemData(
        icon: FontAwesomeIcons.locationDot,
        label: 'Location',
        value: location,
        color: const Color(0xFFEF5350),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _InfoItem(data: items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: 60,
                endIndent: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoItemData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoItemData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _InfoItem extends StatelessWidget {
  final _InfoItemData data;
  const _InfoItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(data.icon, size: 15, color: data.color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Actions card ──────────────────────────────────────────────────────────────

class _ActionsCard extends StatelessWidget {
  final AppLocalizations l10n;
  const _ActionsCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final theme = Theme.of(context);

        final actions = [
          _ActionItemData(
            icon: FontAwesomeIcons.userPen,
            label: l10n.editProfile,
            subtitle: 'Update your personal info',
            color: const Color(0xFF5C6BC0),
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          _ActionItemData(
            icon: FontAwesomeIcons.store,
            label: l10n.shopInformation,
            subtitle: 'Manage your store details',
            color: const Color(0xFF26A69A),
            onTap: () => context.push(AppRoutes.shopInformation),
          ),
          _ActionItemData(
            icon: FontAwesomeIcons.bell,
            label: l10n.notifications,
            subtitle: 'Preferences & alerts',
            color: const Color(0xFFFF7043),
            onTap: () => context.push(AppRoutes.notifications),
          ),
          _ActionItemData(
            icon: FontAwesomeIcons.circleQuestion,
            label: l10n.drawerHelpSupport,
            subtitle: 'FAQs & guides',
            color: const Color(0xFF8D6E63),
            onTap: () => context.push(AppRoutes.helpSupport),
          ),
          _ActionItemData(
            icon: FontAwesomeIcons.addressBook,
            label: l10n.contactUsTitle,
            subtitle: 'Talk to our team',
            color: const Color(0xFF42A5F5),
            onTap: () {
              final role =
                  (ref.read(authNotifierProvider).asData?.value?.role ?? '')
                      .toLowerCase();
              if (role == 'admin') {
                context.push(AppRoutes.adminConversations);
              } else {
                context.push(AppRoutes.contactUs);
              }
            },
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                _ActionItem(data: actions[i]),
                if (i < actions.length - 1)
                  Divider(
                    height: 1,
                    indent: 60,
                    endIndent: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActionItemData {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _ActionItemData({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _ActionItem extends StatelessWidget {
  final _ActionItemData data;
  const _ActionItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(data.icon, size: 15, color: data.color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      data.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.45,
                        ),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                FontAwesomeIcons.chevronRight,
                size: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared decorative circle ──────────────────────────────────────────────────

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  final Color color;
  const _DecorCircle({
    required this.size,
    required this.opacity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }
}
