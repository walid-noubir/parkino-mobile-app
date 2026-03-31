import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'localization/app_localizations.dart';
import 'providers/language_provider.dart';
import 'providers/firebase_auth_provider.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'firebase_options.dart';
import 'services/parking_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialisé avec succès');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de Firebase: $e');
  }

  // 🚀 Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://mjkpbenrruzjlwdwvaaw.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1qa3BiZW5ycnV6amx3ZHd2YWF3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM0MTA1NzQsImV4cCI6MjA4ODk4NjU3NH0.sU7wtKmktoH5wAGcDYJ_XWqiQjlD2CkV4Vwqrv_5nDs',
    );
    print('✅ Supabase initialisé avec succès');
  } catch (e) {
    print('❌ Erreur lors de l\'initialisation de Supabase: $e');
  }

  // 🚀 Initialize parking structure
  try {
    final repository = ParkingRepository();
    print('🚀 Initializing parking structure...');
    await repository.createMainParkingFloors();
    print('✅ Parking structure ready!');
  } catch (e) {
    print('❌ Error initializing parking structure: $e');
  }
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => FirebaseAuthProvider()),
      ],
      child: const ParkinoApp(),
    ),
  );
}

/// Root application widget for Parkino
/// 
/// Provides global theming, navigation, and configuration for the entire app.
/// Supports multi-language: English, French, and Arabic.
class ParkinoApp extends StatefulWidget {
  const ParkinoApp({super.key});

  @override
  State<ParkinoApp> createState() => _ParkinoAppState();
}

class _ParkinoAppState extends State<ParkinoApp> {
  void _changeLanguage(String locale) {
    context.read<LanguageProvider>().setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageProvider>().locale;
    
    return MaterialApp(
      title: 'Parkino',
      debugShowCheckedModeBanner: false,
      theme: _buildParkinoTheme(),
      home: const SignInScreen(),
      locale: Locale(locale),
      routes: {
        '/signin': (context) => const SignInScreen(),
        '/password-reset': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          if (args != null) {
            return PasswordResetScreen(oobCode: args);
          }
          return const SignInScreen();
        },
      },
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  /// Build the Parkino-themed ThemeData
  /// 
  /// Defines colors, typography, and component styles that reflect
  /// Parkino's brand identity with dark blue primary and golden accents.
  static ThemeData _buildParkinoTheme() {
    const Color primaryDarkBlue = Color(0xFF0B2A4A);
    const Color goldenYellow = Color(0xFFFFC107);
    const Color white = Color(0xFFFFFFFF);
    const Color lightGray = Color(0xFFF5F5F5);
    const Color borderGray = Color(0xFFE0E0E0);

    return ThemeData(
      useMaterial3: true,
      
      /// Color Scheme Configuration
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDarkBlue,
        primary: primaryDarkBlue,
        secondary: goldenYellow,
        surface: white,
        brightness: Brightness.light,
      ),

      /// Scaffold Configuration
      scaffoldBackgroundColor: white,

      /// AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDarkBlue,
        foregroundColor: white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
          letterSpacing: 0.5,
        ),
      ),

      /// Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldenYellow,
          foregroundColor: primaryDarkBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      /// Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDarkBlue,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          side: const BorderSide(
            color: primaryDarkBlue,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      /// Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldenYellow,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      /// Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldenYellow),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldenYellow),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: goldenYellow,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFD32F2F),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFD32F2F),
            width: 2,
          ),
        ),
        prefixIconColor: goldenYellow,
        suffixIconColor: goldenYellow,
        hintStyle: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 14,
        ),
        labelStyle: const TextStyle(
          color: goldenYellow,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),

      /// Text Theme
      textTheme: const TextTheme(
        // Headlines
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryDarkBlue,
          letterSpacing: 0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: primaryDarkBlue,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
        ),

        // Body Text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF424242),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: Color(0xFF616161),
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: Color(0xFF9E9E9E),
        ),

        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryDarkBlue,
          letterSpacing: 0.5,
        ),
      ),

      /// Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return goldenYellow;
          }
          return Colors.white;
        }),
        side: const BorderSide(color: goldenYellow, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      /// Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryDarkBlue,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF616161),
        ),
      ),

      /// Snackbar Theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: primaryDarkBlue,
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
      ),

      /// Card Theme
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      /// Icon Theme
      iconTheme: const IconThemeData(
        color: primaryDarkBlue,
        size: 24,
      ),

      /// Divider Theme
      dividerTheme: const DividerThemeData(
        color: borderGray,
        thickness: 1,
        space: 16,
      ),
    );
  }
}


