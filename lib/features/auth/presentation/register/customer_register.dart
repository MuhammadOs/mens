import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';
import 'package:mens/shared/widgets/app_back_button.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterCustomerScreen extends ConsumerStatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  ConsumerState<RegisterCustomerScreen> createState() =>
      _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState
    extends ConsumerState<RegisterCustomerScreen> {
  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  DateTime? _birthDate;
  final _dateController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureRepeat = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    final l10n = ref.read(l10nProvider);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // Show a simple loading dialog
    showDialog(
      context: rootCtx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Build request body
      final body = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        // API may expect date in ISO format
        if (_birthDate != null)
          'birthDate': DateFormat('yyyy-MM-dd').format(_birthDate!),
        'role': 'Customer',
      };

      final uri = Uri.parse(
        'https://mens-shop-api-fhgf2.ondigitalocean.app/api/user/register',
      );
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      Navigator.of(rootCtx).pop(); // close loading
      setState(() => _isLoading = false);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - show confirmation and route to sign-in or user home
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.registrationSuccess)));
        // Navigate to sign-in so user can login
        context.go(AppRoutes.signIn);
      } else {
        // Try to decode error message
        String message = 'Registration failed';
        try {
          final data = jsonDecode(response.body);
          if (data is Map && data['message'] != null)
            message = data['message'].toString();
          else if (data is Map && data['errors'] != null)
            message = data['errors'].toString();
          else
            message = response.body;
        } catch (_) {
          message = response.body.isNotEmpty ? response.body : message;
        }
        showDialog(
          context: rootCtx,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  FontAwesomeIcons.circleExclamation,
                  color: Theme.of(ctx).colorScheme.error,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.errorRegistering)),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.ok),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(rootCtx).pop();
      setState(() => _isLoading = false);
      showDialog(
        context: rootCtx,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              Icon(
                FontAwesomeIcons.circleExclamation,
                color: Theme.of(ctx).colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(l10n.errorRegistering)),
            ],
          ),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.ok),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AppBackButton(
          size: 36,
          backgroundColor: const Color(0xFF0F3B5C),
          iconColor: Colors.white,
          onPressed: () => context.go(AppRoutes.roleSelection),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: ClipOval(
                  child: Image.asset(
                    'assets/mens_logo.png',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          l10n.registerPageTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              labelText: l10n.firstNameLabel,
                              hintText: l10n.firstNameHint,
                              controller: _firstNameController,
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? l10n.validationRequired
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomTextField(
                              labelText: l10n.lastNameLabel,
                              hintText: l10n.lastNameHint,
                              controller: _lastNameController,
                              validator: (v) => (v ?? '').trim().isEmpty
                                  ? l10n.validationRequired
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        labelText: l10n.emailLabel,
                        controller: _emailController,
                        hintText: l10n.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final val = (v ?? '').trim();
                          if (val.isEmpty) return l10n.validationRequired;
                          if (!val.contains('@') && val.length < 9)
                            return l10n.validationEmailInvalid;
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.birthDateLabel,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.9,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _dateController,
                            readOnly: true,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'YYYY-MM-DD',
                              suffixIcon: Icon(
                                FontAwesomeIcons.calendar,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.5,
                                ),
                              ),
                            ),
                            onTap: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    _birthDate ?? DateTime(now.year - 20),
                                firstDate: DateTime(1900),
                                lastDate: now,
                                builder: (context, child) {
                                  return Theme(data: theme, child: child!);
                                },
                              );
                              if (picked != null) {
                                final formatted = DateFormat(
                                  'dd-MM-yyyy',
                                ).format(picked);
                                setState(() {
                                  _birthDate = picked;
                                  _dateController.text = formatted;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        labelText: l10n.passwordLabel,
                        controller: _passwordController,
                        isPassword: true,
                        isPasswordVisible: !_obscurePassword,
                        onVisibilityToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (v) => (v ?? '').length < 6
                            ? l10n.validationPasswordShort
                            : null,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        labelText: l10n.repeatPasswordLabel,
                        controller: _repeatPasswordController,
                        isPassword: true,
                        isPasswordVisible: !_obscureRepeat,
                        onVisibilityToggle: () =>
                            setState(() => _obscureRepeat = !_obscureRepeat),
                        validator: (v) => v != _passwordController.text
                            ? l10n.validationPasswordMismatch
                            : null,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          child: _isLoading
                              ? SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: theme.colorScheme.onPrimary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  l10n.registerButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: TextStyle(color: theme.colorScheme.onBackground),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Use go_router to navigate to the sign in screen
                      context.go(AppRoutes.signIn);
                    },
                    child: Text(
                      l10n.signIn,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
