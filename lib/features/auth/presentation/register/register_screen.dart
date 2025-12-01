import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/shared/widgets/app_back_button.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart';
import 'package:mens/features/auth/presentation/register/brand_info_step.dart';
import 'package:mens/features/auth/presentation/register/owner_info_step.dart';
import 'package:mens/features/auth/presentation/register/profile_info_step.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final registerState = ref.watch(registerNotifierProvider);
    final registerNotifier = ref.read(registerNotifierProvider.notifier);
    // read theme/locale only when needed (kept for side-effects in menu)

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen for registration status to show messages or navigate.
    ref.listen(
      registerNotifierProvider.select((value) => value.registrationStatus),
      (previous, next) {
        if (next is AsyncError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final rootCtx = Navigator.of(context, rootNavigator: true).context;
            if (!rootCtx.mounted) return;
            showDialog(
              context: rootCtx,
              builder: (ctx) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(ctx).colorScheme.error,
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l10n.errorRegistering)),
                  ],
                ),
                content: Text(next.error?.toString() ?? 'Unknown error'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(l10n.ok),
                  ),
                ],
              ),
            );
          });
        } else if (next is AsyncData && next.value == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final rootCtx = Navigator.of(context, rootNavigator: true).context;
            if (!rootCtx.mounted) return;
            showDialog(
              context: rootCtx,
              builder: (ctx) {
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                });
                return AlertDialog(
                  title: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Text(l10n.registerPageTitle),
                    ],
                  ),
                  content: Text(l10n.registrationSuccess),
                );
              },
            );
          });
        }
      },
    );

    final steps = [
      const OwnerInfoStep(),
      const BrandInfoStep(),
      const ProfileInfoStep(),
    ];

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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                      l10n.registerPageTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStepIndicator(
                      context,
                      registerState.currentStep,
                      colorScheme.primary,
                      colorScheme.onSurface.withOpacity(0.3),
                      l10n,
                    ),
                    const SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: Container(
                        key: ValueKey<int>(registerState.currentStep),
                        child: steps[registerState.currentStep],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Back Button (Icon only)
                  if (registerState.currentStep > 0)
                    AppBackButton(
                      size: 36,
                      backgroundColor: const Color(0xFF0F3B5C),
                      iconColor: Colors.white,
                      onPressed: registerNotifier.previousStep,
                    ),
                  if (registerState.currentStep > 0) const SizedBox(width: 16),
                  // Next/Register Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: registerState.registrationStatus.isLoading
                            ? null
                            : () {
                                // TODO: Add form validation
                                if (registerState.currentStep < 2) {
                                  registerNotifier.nextStep();
                                } else {
                                  registerNotifier.register();
                                }
                              },
                        child: Text(
                          registerState.currentStep == 2
                              ? l10n.registerButton
                              : l10n.nextButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildRichTextLink(
                context: context,
                text: l10n.alreadyHaveAccount,
                linkText: l10n.signIn,
                onTap: () => context.go(AppRoutes.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    int currentStep,
    Color activeColor,
    Color inactiveColor,
    AppLocalizations l10n,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepItem(
          context,
          0,
          currentStep,
          activeColor,
          inactiveColor,
          l10n.ownerInfo,
        ),
        _buildStepLine(context, 0, currentStep, activeColor, inactiveColor),
        _buildStepItem(
          context,
          1,
          currentStep,
          activeColor,
          inactiveColor,
          l10n.brandInfo,
        ),
        _buildStepLine(context, 1, currentStep, activeColor, inactiveColor),
        _buildStepItem(
          context,
          2,
          currentStep,
          activeColor,
          inactiveColor,
          l10n.profile,
        ),
      ],
    );
  }

  Widget _buildStepItem(
    BuildContext context,
    int stepIndex,
    int currentStep,
    Color activeColor,
    Color inactiveColor,
    String label,
  ) {
    final bool isActive = stepIndex <= currentStep;
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : inactiveColor.withOpacity(0.2),
            border: Border.all(
              color: isActive ? activeColor : inactiveColor,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              '${stepIndex + 1}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isActive ? activeColor : inactiveColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(
    BuildContext context,
    int stepIndex,
    int currentStep,
    Color activeColor,
    Color inactiveColor,
  ) {
    final bool isLineActive = stepIndex < currentStep;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: isLineActive ? activeColor : inactiveColor,
      ),
    );
  }

  Widget _buildRichTextLink({
    required BuildContext context,
    required String text,
    required String linkText,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
                fontSize: 14,
              ),
              children: [
                TextSpan(text: text),
                TextSpan(
                  text: linkText,
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
