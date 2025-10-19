import 'dart:io'; // Required for Image.file
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mens/core/localization/l10n_provider.dart';
import 'package:mens/features/auth/notifiers/register_notifier.dart'; // Ensure this path is correct
import 'package:mens/shared/widgets/custom_text_field.dart';

class ProfileInfoStep extends HookConsumerWidget {
  const ProfileInfoStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(l10nProvider);
    final registerNotifier = ref.read(registerNotifierProvider.notifier);
    final profileInfo = ref.watch(
      registerNotifierProvider.select((state) => state.profileInfo),
    );

    final emailController = useTextEditingController(text: profileInfo.email);
    final passwordController = useTextEditingController(
      text: profileInfo.password,
    );
    final repeatPasswordController = useTextEditingController(
      text: profileInfo.repeatPassword,
    );

    final isPasswordVisible = useState(false);
    final isRepeatPasswordVisible = useState(false);

    // Update notifier on field changes (Consider using onChanged on CustomTextField for this)
    useEffect(() {
      void listener() {
        registerNotifier.updateProfileInfo(
          email: emailController.text,
          password: passwordController.text,
          repeatPassword: repeatPasswordController.text,
        );
      }

      emailController.addListener(listener);
      passwordController.addListener(listener);
      repeatPasswordController.addListener(listener);
      return () {
        emailController.removeListener(listener);
        passwordController.removeListener(listener);
        repeatPasswordController.removeListener(listener);
      };
    }, []);

    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        registerNotifier.updateProfileInfo(brandImage: image);
      }
    }

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: InkWell(
            onTap: pickImage,
            borderRadius: BorderRadius.circular(75),
            child: DottedBorder(
              options: CircularDottedBorderOptions(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                strokeWidth: 1.5,
                dashPattern: const [6, 6],
              ),
              child: Container(
                height: 120,
                width: 120,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: profileInfo.brandImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cloud_upload_outlined,
                            color: theme.colorScheme.primary,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.tapToUploadPicture,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.7,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : ClipOval(
                        child: Image.file(
                          File(profileInfo.brandImage!.path),
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: l10n.emailLabel,
          hintText: l10n.emailHint,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.validationEmailEmpty;
            }
            if (!value.contains('@')) {
              return l10n.validationEmailInvalid;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          labelText: l10n.passwordLabel,
          hintText: l10n.passwordHint,
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
        const SizedBox(height: 16),
        CustomTextField(
          labelText: l10n.repeatPasswordLabel,
          hintText: l10n.repeatPasswordHint,
          controller: repeatPasswordController,
          isPassword: true,
          isPasswordVisible: isRepeatPasswordVisible.value,
          onVisibilityToggle: () {
            isRepeatPasswordVisible.value = !isRepeatPasswordVisible.value;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.validationPasswordEmpty;
            }
            if (value != passwordController.text) {
              return l10n.validationPasswordMismatch;
            }
            return null;
          },
        ),
      ],
    );
  }
}
