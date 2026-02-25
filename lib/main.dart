// import 'package:device_preview/device_preview.dart';
import 'package:device_preview/device_preview.dart' show DevicePreview;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/core/localization/locale_provider.dart';
import 'package:mens/core/routing/app_router.dart';
import 'package:mens/features/auth/data/auth_repository_impl.dart' as auth_repo;
import 'package:mens/shared/theme/app_theme.dart';
import 'package:mens/shared/theme/theme_provider.dart';
import 'package:mens/shared/widgets/loading_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mens/features/user/profile/data/checkout_preferences_repository.dart' as checkout_prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final languageCode = prefs.getString('languageCode') ?? 'en';
  final initialLocale = Locale(languageCode);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ProviderScope(
        overrides: [
          initialLocaleProvider.overrideWithValue(initialLocale),
          auth_repo.sharedPreferencesProvider.overrideWithValue(prefs),
          checkout_prefs.sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const Mens(),
      ),
    ),
  );
}

class Mens extends ConsumerWidget {
  const Mens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: "Men's",
      routerConfig: router,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      builder: (context, child) {
        final widget = LoadingOverlay(child: child ?? const SizedBox.shrink());
        return DevicePreview.appBuilder(context, widget);
      },
    );
  }
}
