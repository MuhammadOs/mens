import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mens/core/localization/locale_provider.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/notifiers/auth_notifier.dart';
import 'package:mens/shared/theme/theme_provider.dart';
import 'package:mens/shared/widgets/custom_text_field.dart';

class SignInScreen extends HookConsumerWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final authState = ref.watch(authNotifierProvider);

    // Hooks for UI state
    final isPasswordVisible = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 2. Listen for errors or success from the AuthNotifier and show dialogs
    ref.listen(authNotifierProvider, (previous, next) {
      // On error, show an error dialog
      if (next is AsyncError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error'),
              content: Text(next.error?.toString() ?? 'Unknown error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }

      // On successful login (user profile returned), show a success dialog
      if (next is AsyncData && next.value != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Success'),
              content: const Text('You have signed in successfully.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    });

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.settings,
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                      onSelected: (value) {
                        if (value == 'toggle_theme') {
                          ref
                              .read(themeProvider.notifier)
                              .setTheme(
                                currentTheme == ThemeMode.dark
                                    ? ThemeMode.light
                                    : ThemeMode.dark,
                              );
                        } else if (value == 'toggle_locale') {
                          ref
                              .read(localeProvider.notifier)
                              .setLocale(
                                currentLocale.languageCode == 'en'
                                    ? AppLocales.arabic
                                    : AppLocales.english,
                              );
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          value: 'toggle_theme',
                          child: Row(
                            children: [
                              Icon(
                                currentTheme == ThemeMode.dark
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                                color: colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentTheme == ThemeMode.dark
                                    ? l10n.lightTheme
                                    : l10n.darkTheme,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle_locale',
                          child: Row(
                            children: [
                              Icon(
                                Icons.language,
                                color: colorScheme.onSurface,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                currentLocale.languageCode == 'en'
                                    ? l10n.arabic
                                    : l10n.english,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ClipOval(
                    child: Image.asset(
                      'assets/mens_logo.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24.0),
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
                        l10n.loginPageTitle,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        labelText: l10n.emailLabel,
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.validationEmailEmpty;
                          }
                          // ✅ MODIFIED: Updated validation logic
                          final isEmail = value.contains('@');
                          final isPhone = RegExp(
                            r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$',
                          ).hasMatch(value);
                          if (!isEmail && !isPhone) {
                            return l10n
                                .validationEmailInvalid; // Use a more generic error message
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        labelText: l10n.passwordLabel,
                        controller: passwordController,
                        isPassword: true,
                        isPasswordVisible: isPasswordVisible.value,
                        onVisibilityToggle: () {
                          isPasswordVisible.value = !isPasswordVisible.value;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.validationPasswordEmpty;
                          }
                          if (value.length < 6) {
                            return l10n.validationPasswordShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: authState.isLoading
                              ? null
                              : () {
                                  if (formKey.currentState?.validate() ==
                                      true) {
                                    ref
                                        .read(authNotifierProvider.notifier)
                                        .login(
                                          emailController.text,
                                          passwordController.text,
                                        );
                                  }
                                },
                          child: Text(
                            l10n.loginButton,
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
                const SizedBox(height: 16),
                _buildRichTextLink(
                  context: context,
                  text: l10n.dontHaveAccount,
                  linkText: l10n.register,
                  onTap: () {
                    context.go(AppRoutes.register);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.or,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: 0.4,
                  child: _buildRichTextLink(
                    linkText: l10n.continueAsGuest,
                    text: "",
                    context: context,
                    onTap: () {
                      /* Disabled - TODO: Navigate */
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
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
                color: theme.colorScheme.primary.withOpacity(0.6),
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
