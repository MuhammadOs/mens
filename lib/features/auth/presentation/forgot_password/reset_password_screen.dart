import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/shared/widgets/app_back_button.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';

class ResetPasswordScreen extends HookConsumerWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);
    final isPasswordVisible = useState(false);
    final isConfirmVisible = useState(false);

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;

      isLoading.value = true;

      final error = await ref
          .read(authNotifierProvider.notifier)
          .resetPassword(email, otp, passwordController.text);

      isLoading.value = false;

      if (!context.mounted) return;

      if (error == null) {
        Fluttertoast.showToast(
          msg: l10n.passwordResetSuccess,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        context.go(AppRoutes.signIn);
      } else {
        Fluttertoast.showToast(
          msg: error,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: AppBackButton(
          backgroundColor: const Color(0xFF0F3B5C),
          iconColor: Colors.white,
          onPressed: () => context.pop(),
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
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
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        l10n.resetPasswordTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.resetPasswordDescription,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 28),
                      CustomTextField(
                        labelText: l10n.newPasswordLabel,
                        controller: passwordController,
                        isPassword: true,
                        isPasswordVisible: isPasswordVisible.value,
                        onVisibilityToggle: () {
                          isPasswordVisible.value = !isPasswordVisible.value;
                        },
                        validator: (v) => (v ?? '').length < 6
                            ? l10n.validationPasswordShort
                            : null,
                      ),
                      const SizedBox(height: 15),
                      CustomTextField(
                        labelText: l10n.confirmNewPasswordLabel,
                        controller: confirmPasswordController,
                        isPassword: true,
                        isPasswordVisible: isConfirmVisible.value,
                        onVisibilityToggle: () {
                          isConfirmVisible.value = !isConfirmVisible.value;
                        },
                        validator: (v) => v != passwordController.text
                            ? l10n.validationPasswordMismatch
                            : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading.value ? null : submit,
                          child: isLoading.value
                              ? SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  l10n.resetPasswordButton,
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
            ],
          ),
        ),
      ),
    );
  }
}
