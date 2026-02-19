import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/core/services/api_service.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';
import 'package:mens/shared/widgets/app_back_button.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/presentation/otp/otp_verification_screen.dart';

class RegisterCustomerScreen extends ConsumerStatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  ConsumerState<RegisterCustomerScreen> createState() =>
      _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState
    extends ConsumerState<RegisterCustomerScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureRepeat = true;
  bool _isLoading = false;
  DateTime? _birthDate;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    _nationalIdController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _submit() async {
    final l10n = ref.read(l10nProvider);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(apiServiceProvider);
      final body = <String, dynamic>{
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'nationalId': _nationalIdController.text.trim(),
      };
      if (_birthDate != null) {
        body['birthDate'] = _birthDate!.toIso8601String();
      }
      if (_phoneNumberController.text.trim().isNotEmpty) {
        body['phoneNumber'] = _phoneNumberController.text.trim();
      }

      final response = await dio.post('/auth/register', data: body);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.registrationSuccess)),
        );
        context.push(
          AppRoutes.confirmEmail,
          extra: {
            'email': _emailController.text.trim(),
            'mode': OtpMode.confirmEmail,
          },
        );
      } else {
        final dynamic msg = response.data?['message'];
        _showErrorDialog(l10n.errorRegistering, msg?.toString() ?? 'Registration failed');
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String message = 'A network error occurred during registration.';
      if (e.response != null) {
        final dynamic msg = e.response!.data?['message'];
        message = msg?.toString() ??
            (e.response!.data?['errors']?.toString() ??
                'Registration failed: ${e.response!.statusCode}');
      }
      _showErrorDialog(ref.read(l10nProvider).errorRegistering, message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorDialog(
        ref.read(l10nProvider).errorRegistering,
        e.toString(),
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    final l10n = ref.read(l10nProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.circleExclamation,
              color: Theme.of(ctx).colorScheme.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title)),
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

                      // First & Last Name
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

                      // Email
                      CustomTextField(
                        labelText: l10n.emailLabel,
                        controller: _emailController,
                        hintText: l10n.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final val = (v ?? '').trim();
                          if (val.isEmpty) return l10n.validationRequired;
                          if (!val.contains('@') && val.length < 9) {
                            return l10n.validationEmailInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // National ID — required, exactly 14 digits
                      CustomTextField(
                        labelText: l10n.nationalIdLabel,
                        hintText: l10n.nationalIdHint,
                        controller: _nationalIdController,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final val = (v ?? '').trim();
                          if (val.isEmpty) return l10n.validationRequired;
                          if (val.length != 14) return l10n.nationalIdLength;
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Phone Number — optional
                      CustomTextField(
                        labelText: l10n.phoneNumberLabel,
                        hintText: l10n.phoneNumberHint,
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),

                      // Birth Date — optional date picker
                      InkWell(
                        onTap: _selectBirthDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: l10n.birthDateLabel,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _birthDate != null
                                ? '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}'
                                : l10n.birthDateHint,
                            style: TextStyle(
                              color: _birthDate != null
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Password
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

                      // Repeat Password
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

                      // Register Button
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
                    style: TextStyle(color: theme.colorScheme.onSurface),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.signIn),
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
