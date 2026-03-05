import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlTDF5sMhq7PUvKufedZ32TGz_bTJFafg',
    appId: '1:909198990943:android:8293f4b889729a122105ea',
    messagingSenderId: '909198990943',
    projectId: 'parkino-cloud',
    storageBucket: 'parkino-cloud.firebasestorage.app',
  );
}
