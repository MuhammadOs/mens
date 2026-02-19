import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/shared/widgets/app_back_button.dart';

enum OtpMode { confirmEmail, resetPassword }

class OtpVerificationScreen extends HookConsumerWidget {
  final String email;
  final OtpMode mode;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final otpControllers = List.generate(
      6,
      (_) => useTextEditingController(),
    );
    final focusNodes = List.generate(6, (_) => useFocusNode());
    final isLoading = useState(false);
    final canResend = useState(true);
    final resendCountdown = useState(0);

    // Countdown timer for resend
    useEffect(() {
      Timer? timer;
      if (!canResend.value && resendCountdown.value > 0) {
        timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (resendCountdown.value <= 1) {
            canResend.value = true;
            resendCountdown.value = 0;
          } else {
            resendCountdown.value--;
          }
        });
      }
      return () => timer?.cancel();
    }, [canResend.value, resendCountdown.value]);

    Future<void> submitOtp() async {
      final otp = otpControllers.map((c) => c.text).join();
      if (otp.length != 6) {
        Fluttertoast.showToast(
          msg: l10n.otpHint,
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
        );
        return;
      }

      isLoading.value = true;

      if (mode == OtpMode.confirmEmail) {
        final error = await ref
            .read(authNotifierProvider.notifier)
            .confirmEmail(email, otp);

        isLoading.value = false;

        if (error == null) {
          Fluttertoast.showToast(
            msg: l10n.emailConfirmedSuccess,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
          if (context.mounted) {
            context.go(AppRoutes.signIn);
          }
        } else {
          Fluttertoast.showToast(
            msg: error,
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: colorScheme.error,
            textColor: colorScheme.onError,
          );
        }
      } else {
        // resetPassword mode — navigate to reset password screen with OTP
        isLoading.value = false;
        if (context.mounted) {
          context.push(
            AppRoutes.resetPassword,
            extra: {'email': email, 'otp': otp},
          );
        }
      }
    }

    Future<void> resendOtp() async {
      canResend.value = false;
      resendCountdown.value = 60;

      String? error;
      if (mode == OtpMode.confirmEmail) {
        error = await ref
            .read(authNotifierProvider.notifier)
            .resendConfirmation(email);
      } else {
        error = await ref
            .read(authNotifierProvider.notifier)
            .forgetPassword(email);
      }

      if (error != null) {
        Fluttertoast.showToast(
          msg: error,
          backgroundColor: colorScheme.error,
          textColor: colorScheme.onError,
        );
      } else {
        Fluttertoast.showToast(
          msg: l10n.otpResentSuccess,
          backgroundColor: Colors.green,
          textColor: Colors.white,
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
                child: Column(
                  children: [
                    Text(
                      mode == OtpMode.confirmEmail
                          ? l10n.confirmEmailTitle
                          : l10n.resetPasswordTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.otpSentTo(email),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // OTP input fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 44,
                          height: 52,
                          child: TextField(
                            controller: otpControllers[index],
                            focusNode: focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty && index < 5) {
                                focusNodes[index + 1].requestFocus();
                              }
                              if (value.isEmpty && index > 0) {
                                focusNodes[index - 1].requestFocus();
                              }
                              // Auto-submit when all 6 digits entered
                              final otp = otpControllers
                                  .map((c) => c.text)
                                  .join();
                              if (otp.length == 6) {
                                submitOtp();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading.value ? null : submitOtp,
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
                                l10n.verifyButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: canResend.value ? resendOtp : null,
                      child: Text(
                        canResend.value
                            ? l10n.resendOtp
                            : l10n.resendOtpCountdown(resendCountdown.value),
                        style: TextStyle(
                          color: canResend.value
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ),
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
