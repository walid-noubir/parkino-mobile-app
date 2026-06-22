import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'localization/app_localizations.dart';
import 'providers/language_provider.dart';
import 'providers/firebase_auth_provider.dart';
import 'providers/slot_reservation_provider.dart';
import 'providers/reservation_notification_provider.dart';
import 'providers/parking_provider.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/auth/password_reset_screen.dart';
import 'firebase_options.dart';
import 'services/parking_repository.dart';
import 'theme/parkino_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialisé avec succès');
  } catch (e) {
    print('Erreur lors de l\'initialisation de Firebase: $e');
  }


  // Initialize parking structure - only creates if it doesn't exist yet
  final repository = ParkingRepository();
  await repository.createMainParkingFloors();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => FirebaseAuthProvider()),
        ChangeNotifierProvider(create: (context) => ParkingProvider()..startListening()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
        ChangeNotifierProvider(
          create: (context) {
            final slotReservationProvider = SlotReservationProvider();
            // Connecter le NotificationProvider au SlotReservationProvider
            final notificationProvider = context.read<NotificationProvider>();
            slotReservationProvider.setNotificationProvider(notificationProvider);
            // NEW: Set up auth listener for auto-reset on logout
            final authProvider = context.read<FirebaseAuthProvider>();
            slotReservationProvider.setupAuthListener(authProvider);
            return slotReservationProvider;
          },
        ),
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
  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageProvider>().locale;
    
    return MaterialApp(
      title: 'Parkino',
      debugShowCheckedModeBanner: false,
      theme: ParkinoTheme.buildTheme(),
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
      navigatorObservers: [_NavigatorObserver()],
    );
  }
}

/// Observer pour stabiliser le Navigator pendant les changements de langue
class _NavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
  }
}
