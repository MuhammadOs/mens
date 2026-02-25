import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/user/addresses/domain/address.dart';
import 'package:mens/features/user/addresses/notifiers/address_notifier.dart';

class AddressFormScreen extends ConsumerStatefulWidget {
  final Address? address;
  const AddressFormScreen({super.key, this.address});

  @override
  ConsumerState<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends ConsumerState<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cityController;
  late TextEditingController _streetController;
  late TextEditingController _buildingController;
  late TextEditingController _floorController;
  late TextEditingController _flatController;
  late TextEditingController _notesController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.address?.city);
    _streetController = TextEditingController(text: widget.address?.street);
    _buildingController = TextEditingController(text: widget.address?.buildingNo);
    _floorController = TextEditingController(text: widget.address?.floorNo);
    _flatController = TextEditingController(text: widget.address?.flatNo);
    _notesController = TextEditingController(text: widget.address?.notes);
    _isDefault = widget.address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _cityController.dispose();
    _streetController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _flatController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final address = Address(
      id: widget.address?.id,
      city: _cityController.text,
      street: _streetController.text,
      buildingNo: _buildingController.text,
      floorNo: _floorController.text,
      flatNo: _flatController.text,
      notes: _notesController.text,
      isDefault: _isDefault,
    );

    try {
      if (widget.address == null) {
        await ref.read(addressNotifierProvider.notifier).addAddress(address);
      } else {
        await ref
            .read(addressNotifierProvider.notifier)
            .updateAddress(widget.address!.id!, address);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final isEditing = widget.address != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add Address'),
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(FontAwesomeIcons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(l10n.locationLabel, theme),
              _buildTextField(
                controller: _cityController,
                label: l10n.city,
                icon: FontAwesomeIcons.city,
                validator: (v) => v!.isEmpty ? l10n.validationRequired : null,
              ),
              _buildTextField(
                controller: _streetController,
                label: l10n.street,
                icon: FontAwesomeIcons.road,
                validator: (v) => v!.isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _buildingController,
                      label: l10n.building,
                      icon: FontAwesomeIcons.building,
                      validator: (v) => v!.isEmpty ? l10n.validationRequired : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _floorController,
                      label: l10n.floor,
                      icon: FontAwesomeIcons.stairs,
                      validator: (v) => v!.isEmpty ? l10n.validationRequired : null,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _flatController,
                label: l10n.flat,
                icon: FontAwesomeIcons.doorOpen,
                validator: (v) => v!.isEmpty ? l10n.validationRequired : null,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(l10n.additionalNotes, theme),
              _buildTextField(
                controller: _notesController,
                label: l10n.notes,
                icon: FontAwesomeIcons.noteSticky,
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text(l10n.saveAsDefaultAddress),
                subtitle: Text(l10n.useAsDefaultAddressDesc),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                activeThumbColor: theme.colorScheme.primary,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(
                    isEditing ? l10n.save : l10n.addProduct, // Fallback if no "Add"
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
        ),
      ),
    );
  }
}
