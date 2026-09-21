/// Localizations for the WMS apps (az default, en, ru).
library;

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'src/generated/app_localizations.dart';

export 'src/generated/app_localizations.dart';

/// Convenience accessors for `MaterialApp`.
abstract final class WmsL10n {
  /// Default locale: Azerbaijani.
  static const Locale defaultLocale = Locale('az');

  static const List<Locale> supportedLocales =
      AppLocalizations.supportedLocales;

  static const List<LocalizationsDelegate<Object?>> delegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  /// Resolves the app locale from the device locales, falling back to `az`.
  static Locale resolve(
    List<Locale>? deviceLocales,
    Iterable<Locale> supported,
  ) {
    for (final locale in deviceLocales ?? const <Locale>[]) {
      for (final candidate in supported) {
        if (candidate.languageCode == locale.languageCode) return candidate;
      }
    }
    return defaultLocale;
  }
}

/// `context.l10n` shortcut.
extension WmsL10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
