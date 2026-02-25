import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/user/addresses/domain/address.dart';
import 'package:mens/features/user/addresses/notifiers/address_notifier.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddressListScreen extends ConsumerWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final addressesAsync = ref.watch(addressNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addresses),
        centerTitle: true,
      ),
      body: addressesAsync.when(
        data: (addresses) {
          if (addresses.isEmpty) {
            return _buildEmptyState(context, l10n, theme);
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(addressNotifierProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                final address = addresses[index];
                return _AddressCard(address: address);
              },
            ),
          );
        },
        loading: () => Skeletonizer(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) => const _AddressCardSkeleton(),
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.errorLoading),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(addressNotifierProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addAddress),
        icon: const Icon(FontAwesomeIcons.plus),
        label: Text(l10n.addProduct), // Use "Add" localization if available
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.mapLocationDot, 
               size: 80, 
               color: theme.colorScheme.primary.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          Text(
            l10n.addressesEmpty ?? 'No addresses saved yet',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n.saveShippingDetailsDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final Address address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = ref.watch(l10nProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: address.isDefault
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : Border.all(color: theme.colorScheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            if (address.isDefault)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: theme.colorScheme.primary,
                child: Text(
                  l10n.defaultShippingAddress,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FontAwesomeIcons.locationDot,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${address.city}, ${address.street}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${l10n.building}: ${address.buildingNo}, ${l10n.floor}: ${address.floorNo}, ${l10n.flat}: ${address.flatNo}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        if (address.notes != null && address.notes!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            address.notes!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!address.isDefault)
                    TextButton(
                      onPressed: () => ref
                          .read(addressNotifierProvider.notifier)
                          .setDefaultAddress(address.id!),
                      child: Text(l10n.saveAsDefaultAddress),
                    ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.penToSquare, size: 18),
                    onPressed: () => context.push(
                      AppRoutes.editAddress.replaceFirst(':id', address.id.toString()),
                      extra: address,
                    ),
                    color: theme.colorScheme.primary,
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.trashCan, size: 18),
                    onPressed: () => _confirmDelete(context, ref, address),
                    color: theme.colorScheme.error,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(addressNotifierProvider.notifier).deleteAddress(address.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _AddressCardSkeleton extends StatelessWidget {
  const _AddressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
