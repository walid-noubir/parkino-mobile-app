import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/app_localizations.dart';
import '../main.dart';
import '../providers/language_provider.dart';
import '../widgets/language_settings_sheet.dart';

/// Language Button Widget
/// Displays current language and allows changing it
class LanguageButton extends StatefulWidget {
  const LanguageButton({super.key});

  @override
  State<LanguageButton> createState() => _LanguageButtonState();
}

class _LanguageButtonState extends State<LanguageButton> {
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (sheetContext) {
        final currentLanguage = context.read<LanguageProvider>().locale;
        return LanguageSettingsSheet(
          currentLanguage: currentLanguage,
          onLanguageChanged: (String newLocale) {
            try {
              if (Navigator.of(sheetContext).canPop()) {
                Navigator.of(sheetContext).pop();
              }
            } catch (e) {
              // Ignore navigation errors
            }
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              try {
                context.read<LanguageProvider>().setLocale(newLocale);
              } catch (e) {
                // Ignore language change errors
              }
            });
          },
        );
      },
    );
  }

  String _getLanguageDisplay(String locale) {
    switch (locale) {
      case 'fr':
        return '🇫🇷 FR';
      case 'ar':
        return '🇸🇦 AR';
      default:
        return '🇬🇧 EN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageProvider>().locale;
    
    return GestureDetector(
      onTap: _showLanguageSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _goldenYellow.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _goldenYellow,
            width: 1.5,
          ),
        ),
        child: Text(
          _getLanguageDisplay(locale),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _primaryDarkBlue,
          ),
        ),
      ),
    );
  }
}
