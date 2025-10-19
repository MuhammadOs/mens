import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mens/core/localization/l10n/app_localizations.dart';
import 'package:mens/core/localization/locale_provider.dart';

/// A provider that supplies the correct AppLocalizations object based on the current locale.
///
/// This is the key to solving the UI update issue, as it bypasses the need for
/// a `BuildContext` to get translation strings.
final l10nProvider = Provider<AppLocalizations>((ref) {
  // 1. Watch the localeProvider. When the locale changes, this provider will automatically re-run.
  final locale = ref.watch(localeProvider);

  // 2. Use Flutter's generated lookup function to get the correct translations
  // for the currently selected locale.
  return lookupAppLocalizations(locale);
});
