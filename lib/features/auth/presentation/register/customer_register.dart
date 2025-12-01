import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';
import 'package:mens/shared/widgets/app_back_button.dart';
import 'package:intl/intl.dart';

class RegisterCustomerScreen extends StatefulWidget {
  const RegisterCustomerScreen({super.key});

  @override
  State<RegisterCustomerScreen> createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends State<RegisterCustomerScreen> {
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

    if (!_formKey.currentState!.validate()) return;

    // Show a simple loading dialog
    showDialog(
      context: rootCtx,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Simulate network call
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      // Close loading
      Navigator.of(rootCtx).pop();

      // Show success
      showDialog(
        context: rootCtx,
        builder: (ctx) => AlertDialog(
          title: const Text('Success'),
          content: const Text('Account created successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Navigate to unified user home (4-tab) after registration
                context.go(AppRoutes.userHome);
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(rootCtx).pop();
      showDialog(
        context: rootCtx,
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(rootCtx).pop(),
              child: const Text('OK'),
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
                          'Register',
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
                              labelText: 'First Name',
                              controller: _firstNameController,
                              validator: (v) =>
                                  (v ?? '').trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CustomTextField(
                              labelText: 'Last Name',
                              controller: _lastNameController,
                              validator: (v) =>
                                  (v ?? '').trim().isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      CustomTextField(
                        labelText: 'Email or phone number',
                        controller: _emailController,
                        hintText: 'user@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final val = (v ?? '').trim();
                          if (val.isEmpty) return 'Required';
                          if (!val.contains('@') && val.length < 9)
                            return 'Enter a valid email or phone';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Birth Date',
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
                                Icons.calendar_today,
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
                        labelText: 'Enter Your Password',
                        controller: _passwordController,
                        isPassword: true,
                        isPasswordVisible: !_obscurePassword,
                        onVisibilityToggle: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        validator: (v) =>
                            (v ?? '').length < 6 ? 'Min 6 characters' : null,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        labelText: 'Repeat Password',
                        controller: _repeatPasswordController,
                        isPassword: true,
                        isPasswordVisible: !_obscureRepeat,
                        onVisibilityToggle: () =>
                            setState(() => _obscureRepeat = !_obscureRepeat),
                        validator: (v) => v != _passwordController.text
                            ? 'Passwords do not match'
                            : null,
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18,
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
                    'Already has an account? ',
                    style: TextStyle(color: theme.colorScheme.onBackground),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Use go_router to navigate to the sign in screen
                      context.go(AppRoutes.signIn);
                    },
                    child: Text(
                      'Sign In',
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
