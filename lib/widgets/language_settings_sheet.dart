import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/parkino_theme.dart';

/// Language Settings Bottom Sheet
/// Allows users to change app language between English, French, and Arabic
class LanguageSettingsSheet extends StatefulWidget {
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  const LanguageSettingsSheet({
    super.key,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });

  @override
  State<LanguageSettingsSheet> createState() => _LanguageSettingsSheetState();
}

class _LanguageSettingsSheetState extends State<LanguageSettingsSheet> {
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);

  final List<Map<String, String>> languages = [
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ParkinoTheme.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _primaryDarkBlue,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close_rounded,
                    color: _primaryDarkBlue,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Language options
            ...languages.map((lang) {
              final isSelected = widget.currentLanguage == lang['code'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    if (!isSelected) {
                      // Don't pop here - let the callback handle navigation
                      widget.onLanguageChanged(lang['code']!);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _goldenYellow.withValues(alpha: 0.15)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? _goldenYellow : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          lang['flag']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryDarkBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _goldenYellow,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: ParkinoTheme.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
