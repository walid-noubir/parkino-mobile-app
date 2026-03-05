/// Localization class for Parkino app
/// Supports English, French, and Arabic languages

class AppLocalizations {
  static const String _defaultLocale = 'en';
  static String _currentLocale = _defaultLocale;

  // English translations
  static const Map<String, String> _en = {
    // Common
    'app_name': 'Parkino',
    'sign_in': 'Sign In',
    'sign_up': 'Sign Up',
    'create_account': 'Create an account',
    'forgot_password': 'Forgot Password?',
    'remember_me': 'Remember me',
    'password': 'Password',
    'email': 'Email Address',
    'email_hint': 'you@example.com',
    'password_hint': 'Enter your password',
    'username': 'Username',
    'phone': 'Phone Number',
    'confirm_password': 'Confirm Password',
    'create_an_account': 'Create Your Account',
    'sign_in_title': 'Welcome Back',
    'dont_have_account': "Don't have an account? ",
    'already_have_account': 'Already have an account? ',
    'home': 'Home',
    'map': 'Map',
    'stats': 'Stats',
    'notifications': 'Notifications',
    'profile': 'Profile',
    'parking_availability': 'Parking Availability',
    'current_status': 'Current Status',
    'available': 'AVAILABLE',
    'full': 'FULL',
    'occupied': 'OCCUPIED',
    'free': 'FREE',
    'peak_hours': 'Peak Hours',
    'nearest_spot': 'Nearest Spot',
    'view_parking_map': 'VIEW PARKING MAP',
    'language': 'Language',
    'english': 'English',
    'french': 'Français',
    'arabic': 'العربية',
  };

  // French translations
  static const Map<String, String> _fr = {
    'app_name': 'Parkino',
    'sign_in': 'Se connecter',
    'sign_up': 'S\'inscrire',
    'create_account': 'Créer un compte',
    'forgot_password': 'Mot de passe oublié?',
    'remember_me': 'Se souvenir de moi',
    'password': 'Mot de passe',
    'email': 'Adresse e-mail',
    'email_hint': 'vous@exemple.com',
    'password_hint': 'Entrez votre mot de passe',
    'username': 'Nom d\'utilisateur',
    'phone': 'Numéro de téléphone',
    'confirm_password': 'Confirmer le mot de passe',
    'create_an_account': 'Créer votre compte',
    'sign_in_title': 'Heureux de vous revoir',
    'dont_have_account': "Vous n'avez pas de compte? ",
    'already_have_account': 'Vous avez déjà un compte? ',
    'home': 'Accueil',
    'map': 'Carte',
    'stats': 'Statistiques',
    'notifications': 'Notifications',
    'profile': 'Profil',
    'parking_availability': 'Disponibilité du stationnement',
    'current_status': 'État actuel',
    'available': 'DISPONIBLE',
    'full': 'COMPLET',
    'occupied': 'OCCUPÉ',
    'free': 'LIBRE',
    'peak_hours': 'Heures de pointe',
    'nearest_spot': 'Place la plus proche',
    'view_parking_map': 'VOIR LA CARTE DE STATIONNEMENT',
    'language': 'Langue',
    'english': 'English',
    'french': 'Français',
    'arabic': 'العربية',
  };

  // Arabic translations
  static const Map<String, String> _ar = {
    'app_name': 'باركينو',
    'sign_in': 'تسجيل الدخول',
    'sign_up': 'إنشاء حساب',
    'create_account': 'إنشاء حساب',
    'forgot_password': 'هل نسيت كلمة المرور؟',
    'remember_me': 'تذكرني',
    'password': 'كلمة المرور',
    'email': 'عنوان البريد الإلكتروني',
    'email_hint': 'you@example.com',
    'password_hint': 'أدخل كلمة المرور الخاصة بك',
    'username': 'اسم المستخدم',
    'phone': 'رقم الهاتف',
    'confirm_password': 'تأكيد كلمة المرور',
    'create_an_account': 'إنشاء حسابك',
    'sign_in_title': 'أهلا وسهلا',
    'dont_have_account': 'ليس لديك حساب؟ ',
    'already_have_account': 'هل لديك حساب بالفعل؟ ',
    'home': 'الرئيسية',
    'map': 'الخريطة',
    'stats': 'الإحصائيات',
    'notifications': 'الإخطارات',
    'profile': 'الملف الشخصي',
    'parking_availability': 'توفر مواقف السيارات',
    'current_status': 'الحالة الحالية',
    'available': 'متاح',
    'full': 'ممتلئ',
    'occupied': 'مشغول',
    'free': 'حر',
    'peak_hours': 'ساعات الذروة',
    'nearest_spot': 'أقرب مكان',
    'view_parking_map': 'عرض خريطة المواقف',
    'language': 'اللغة',
    'english': 'English',
    'french': 'Français',
    'arabic': 'العربية',
  };

  /// Get current locale
  static String get currentLocale => _currentLocale;

  /// Set current locale
  static void setLocale(String locale) {
    if (['en', 'fr', 'ar'].contains(locale)) {
      _currentLocale = locale;
    }
  }

  /// Get localized string by key
  static String translate(String key) {
    final Map<String, String> currentMap;
    
    switch (_currentLocale) {
      case 'fr':
        currentMap = _fr;
        break;
      case 'ar':
        currentMap = _ar;
        break;
      default:
        currentMap = _en;
    }
    
    return currentMap[key] ?? key;
  }

  /// Alias for translate method
  static String t(String key) => translate(key);
}
