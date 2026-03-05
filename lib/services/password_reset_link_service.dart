import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

/// Service pour gérer les liens de réinitialisation de mot de passe
class PasswordResetLinkService {
  static final PasswordResetLinkService _instance =
      PasswordResetLinkService._internal();

  factory PasswordResetLinkService() {
    return _instance;
  }

  PasswordResetLinkService._internal();

  /// Listen for password reset links when app is opened from email
  /// Should be called in main.dart or in initState of your main screen
  Future<String?> handlePasswordResetLink() async {
    try {
      // Get the dynamic link if the app was opened from a link
      final PendingDynamicLinkData? data =
          await FirebaseDynamicLinks.instance.getInitialLink();

      if (data != null) {
        return _extractOobCodeFromLink(data.link);
      }

      // Also listen for links opened while app is running
      FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData dynamicLinkData) {
          final String? oobCode = _extractOobCodeFromLink(dynamicLinkData.link);
          if (oobCode != null) {
            // You can emit this through a Stream or callback
            // For now we'll just return it
          }
        },
        onError: (OnLinkErrorException e) {
          print('onLinkError: ${e.message}');
        },
      );

      return null;
    } catch (e) {
      print('Error handling password reset link: $e');
      return null;
    }
  }

  /// Extract OOB code from the dynamic link URI
  /// Firebase password reset links format:
  /// https://yourdomain.page.link/?link=https://yourproject.firebaseapp.com/__/auth/action?oobCode=XXXXX&mode=resetPassword...
  String? _extractOobCodeFromLink(Uri link) {
    try {
      // Check if this is a password reset link
      final String? queryParam = link.queryParameters['link'];

      if (queryParam != null) {
        final Uri deepLink = Uri.parse(queryParam);
        return deepLink.queryParameters['oobCode'];
      }

      // Also check direct parameters
      return link.queryParameters['oobCode'];
    } catch (e) {
      print('Error extracting OOB code: $e');
      return null;
    }
  }

  /// Alternative: Handle Firebase Auth state changes
  /// Some devices may not support Dynamic Links, so also check auth
  /// when the app opens if URL handling doesn't work
  Future<String?> checkPasswordResetFromUrl() async {
    try {
      // This is called when user clicks the email link
      // Firebase will handle the link internally
      // We just need to observe and redirect

      final FirebaseAuth auth = FirebaseAuth.instance;

      // Check if there's a pending action
      // You can also use ActionCodeSettings to create custom links

      return null;
    } catch (e) {
      print('Error checking password reset: $e');
      return null;
    }
  }

  /// Alternative method: Send custom password reset email with app link
  /// This allows more control over the password reset flow
  static Future<void> sendCustomPasswordResetEmail({
    required String email,
    required String appLink, // e.g., "https://parkino.app/reset"
  }) async {
    try {
      final actionCodeSettings = ActionCodeSettings(
        url: appLink,
        handleCodeInApp: false, // Set to false so Firebase handles it
        iOSBundleId: 'com.parkino.app',
        androidPackageName: 'com.parkino.app',
        androidInstallIfNotAvailable: true,
      );

      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
    } catch (e) {
      print('Error sending custom password reset email: $e');
      rethrow;
    }
  }
}
