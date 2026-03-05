import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

/// Language Provider for managing app language
class LanguageProvider extends ChangeNotifier {
  String _locale = 'en';

  String get locale => _locale;

  void setLocale(String newLocale) {
    if (['en', 'fr', 'ar'].contains(newLocale)) {
      _locale = newLocale;
      AppLocalizations.setLocale(newLocale);
      notifyListeners();
    }
  }
}
