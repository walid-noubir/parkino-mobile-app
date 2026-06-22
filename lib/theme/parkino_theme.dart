import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modern Parkino Theme with Glassmorphism effects
/// 
/// Provides a sophisticated, modern design with:
/// - Gradient backgrounds
/// - Glassmorphism effects
/// - Modern animations
/// - Improved typography
class ParkinoTheme {
  // Primary Colors - Modern Gradient
  static const Color primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color primaryMediumBlue = Color(0xFF1E3A5F);
  static const Color primaryLightBlue = Color(0xFF2D5A8C);
  
  // Accent Colors
  static const Color goldenYellow = Color(0xFFFFC107);
  static const Color moderateGolden = Color(0xFFFFB82C);
  static const Color brightAccent = Color(0xFF00D4FF);
  static const Color secondaryAccent = Color(0xFF7C3AED); // Modern purple
  
  // Neutral Colors
  static const Color white = Color(0xFFF4F7FA);
  static const Color veryLightGray = Color(0xFFF8F9FA);
  static const Color lightGray = Color(0xFFF1F3F5);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color darkGray = Color(0xFF6C757D);
  static const Color veryDarkGray = Color(0xFF212529);
  
  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color infoBlue = Color(0xFF3B82F6);

  /// Build the modern Parkino ThemeData
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      
      /// Color Scheme with modern gradients
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDarkBlue,
        primary: primaryDarkBlue,
        onPrimary: white,
        secondary: goldenYellow,
        onSecondary: primaryDarkBlue,
        tertiary: secondaryAccent,
        surface: veryLightGray,
        onSurface: veryDarkGray,
        brightness: Brightness.light,
        error: errorRed,
        onError: white,
      ),

      /// Scaffold Configuration
      scaffoldBackgroundColor: veryLightGray,

      /// AppBar Theme - Modern with shadow
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: white,
          letterSpacing: 0.3,
        ),
        toolbarHeight: 70,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),

      /// Elevated Button Theme - Modern design
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldenYellow,
          foregroundColor: primaryDarkBlue,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          elevation: 4,
          shadowColor: goldenYellow.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),

      /// Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(
            color: goldenYellow,
            width: 2.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      /// Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldenYellow,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      /// Input Decoration Theme - Modern with rounded corners
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: mediumGray,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: mediumGray,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: goldenYellow,
            width: 2.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: errorRed,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: errorRed,
            width: 2.5,
          ),
        ),
        prefixIconColor: MaterialStateColor.resolveWith((states) {
          return states.contains(MaterialState.focused)
              ? goldenYellow
              : darkGray;
        }),
        suffixIconColor: MaterialStateColor.resolveWith((states) {
          return states.contains(MaterialState.focused)
              ? goldenYellow
              : darkGray;
        }),
        hintStyle: GoogleFonts.poppins(
          color: darkGray,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.poppins(
          color: primaryDarkBlue,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          color: goldenYellow,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      /// Text Theme - Modern typography with Poppins
      textTheme: TextTheme(
        // Display texts
        displayLarge: GoogleFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: primaryDarkBlue,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primaryDarkBlue,
          letterSpacing: -0.3,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primaryDarkBlue,
        ),

        // Headline texts
        headlineLarge: GoogleFonts.poppins(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: primaryDarkBlue,
          letterSpacing: 0.2,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
        ),

        // Title texts
        titleLarge: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
        ),
        titleMedium: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
        ),
        titleSmall: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
        ),

        // Body texts
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: veryDarkGray,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkGray,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: darkGray,
          height: 1.4,
        ),

        // Label texts
        labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: primaryDarkBlue,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
          letterSpacing: 0.3,
        ),
        labelSmall: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: darkGray,
          letterSpacing: 0.4,
        ),
      ),

      /// Card Theme - Modern with elevation
      cardTheme: CardThemeData(
        color: white,
        elevation: 0.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: veryDarkGray.withOpacity(0.1),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      /// Divider Theme
      dividerTheme: const DividerThemeData(
        color: mediumGray,
        thickness: 1,
        space: 16,
      ),

      /// Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldenYellow;
          }
          return Colors.transparent;
        }),
        side: const BorderSide(
          color: goldenYellow,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),

      /// Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightGray,
        labelStyle: GoogleFonts.poppins(
          color: primaryDarkBlue,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: mediumGray),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 0,
      ),
    );
  }

  /// Get a glass effect decoration
  static BoxDecoration glassEffect({
    Color backgroundColor = Colors.white,
    double opacity = 0.1,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(20)),
  }) {
    return BoxDecoration(
      color: backgroundColor.withOpacity(opacity),
      borderRadius: borderRadius,
      border: Border.all(
        color: white.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: veryDarkGray.withOpacity(0.08),
          blurRadius: 15,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Get a gradient background
  static LinearGradient modernGradient({
    bool isDark = false,
  }) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [primaryDarkBlue.withOpacity(0.95), primaryMediumBlue.withOpacity(0.9)]
          : [veryLightGray, lightGray],
    );
  }

  /// Get elevation shadow
  static List<BoxShadow> modernShadow({
    double elevation = 8,
  }) {
    return [
      BoxShadow(
        color: veryDarkGray.withOpacity(0.12),
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
        spreadRadius: 0,
      ),
    ];
  }

  /// Get smooth corner radius
  static const BorderRadius smoothRadius = BorderRadius.all(Radius.circular(16));
  static const BorderRadius largeRadius = BorderRadius.all(Radius.circular(24));
  static const BorderRadius extraLargeRadius = BorderRadius.all(Radius.circular(32));
}
