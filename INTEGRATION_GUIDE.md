# Guide d'intégration - Système de réservation de parking

## 📝 Intégration dans `main.dart`

Si vous avez déjà un `main.dart` existant, voici comment intégrer le système de réservation :

### Option 1: Intégration avec un menu

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkino/providers/index.dart';
import 'package:parkino/screens/parking_reservation_hub.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => QRCodeProvider()),
      ],
      child: MaterialApp(
        title: 'Parkino',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkino - Accueil'),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ... autres sections de votre application ...

          // Section Parking
          const SizedBox(height: 24),
          const Text(
            'Services de Parking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.local_parking, color: Colors.blue),
              title: const Text('Réservation de parking'),
              subtitle: const Text('2e Étage - Places B1, B2, B3'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParkingReservationHub(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### Option 2: Remplacer entièrement par le hub

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => QRCodeProvider()),
      ],
      child: MaterialApp(
        title: 'Parkino',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const ParkingReservationHub(),
      ),
    );
  }
}
```

---

## 🔧 Configuration pour Firestore (future intégration)

Si vous souhaitez stocker les données dans Firestore au lieu de la mémoire :

### 1. Créer un service Firestore

```dart
// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parkino/models/index.dart';

class FirestoreReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Reservation> createReservation(Reservation reservation) async {
    await _firestore
        .collection('reservations')
        .doc(reservation.id)
        .set(reservation.toJson());
    return reservation;
  }

  Future<Reservation?> getReservation(String id) async {
    final doc = await _firestore
        .collection('reservations')
        .doc(id)
        .get();
    
    if (doc.exists) {
      return Reservation.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Reservation>> getUserReservations(String userId) async {
    final query = await _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .get();
    
    return query.docs
        .map((doc) => Reservation.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateReservation(Reservation reservation) async {
    await _firestore
        .collection('reservations')
        .doc(reservation.id)
        .update(reservation.toJson());
  }

  // ... autres méthodes
}
```

### 2. Modifier le Provider

```dart
// lib/providers/reservation_provider.dart

class ReservationProvider extends ChangeNotifier {
  final FirestoreReservationService _service = FirestoreReservationService();

  // ... reste du code
}
```

---

## 📱 Points d'extension

### Ajouter une authentification utilisateur

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erreur inscription: $e');
      return null;
    }
  }

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Erreur connexion: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
```

### Scanner QR code avec caméra

```dart
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanner QR')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      // Traiter le QR code scanné
      Navigator.pop(context, scanData.code);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

### Notification de paiement

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings settings = InitializationSettings(
      android: android,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> showPaymentNotification(
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails android = AndroidNotificationDetails(
      'payment_channel',
      'Paiements',
      channelDescription: 'Notifications de paiement',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: android,
    );

    await _notifications.show(
      0,
      title,
      body,
      details,
    );
  }
}
```

---

## 🧪 Tests unitaires

### Test du service de paiement

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:parkino/services/payment_service.dart';

void main() {
  group('PaymentService', () {
    final paymentService = PaymentService();

    test('Accepte la carte approuvée', () async {
      final result = await paymentService.processPayment(
        cardNumber: '4242424242424242',
        expiryDate: '12/25',
        cvv: '123',
        holderName: 'JEAN DUPONT',
        amount: 10.0,
        reservationId: 'res123',
        userId: 'user123',
      );

      expect(result['success'], true);
    });

    test('Rejette la carte rejetée', () async {
      final result = await paymentService.processPayment(
        cardNumber: '4000000000000000',
        expiryDate: '12/25',
        cvv: '123',
        holderName: 'JEAN DUPONT',
        amount: 10.0,
        reservationId: 'res123',
        userId: 'user123',
      );

      expect(result['success'], false);
    });

    test('Valide le numéro de carte', () {
      expect(
        paymentService.validateCardData(
          cardNumber: '4242424242424242',
          expiryDate: '12/25',
          cvv: '123',
          holderName: 'JEAN DUPONT',
        ),
        true,
      );
    });

    test('Rejette un numéro invalide', () {
      expect(
        paymentService.validateCardData(
          cardNumber: '123', // Trop court
          expiryDate: '12/25',
          cvv: '123',
          holderName: 'JEAN DUPONT',
        ),
        false,
      );
    });
  });
}
```

---

## 📊 Statistiques et rapports

### Générer un rapport d'utilisation

```dart
class ReservationReportService {
  static Map<String, dynamic> generateReport(
    List<Reservation> reservations,
    List<Payment> payments,
  ) {
    final totalReservations = reservations.length;
    final totalRevenue = payments
        .where((p) => p.status == PaymentStatus.successful)
        .fold<double>(0, (sum, p) => sum + p.amount);
    
    final usedCount = reservations
        .where((r) => r.status == ReservationStatus.used)
        .length;
    
    final expiredCount = reservations
        .where((r) => r.status == ReservationStatus.expired)
        .length;

    return {
      'totalReservations': totalReservations,
      'totalRevenue': totalRevenue,
      'usedReservations': usedCount,
      'expiredReservations': expiredCount,
      'successRate': totalReservations > 0
          ? (usedCount / totalReservations * 100).toStringAsFixed(2) + '%'
          : '0%',
    };
  }
}
```

---

## 🚀 Déploiement

### Variables d'environnement Firebase

1. Créer un fichier `.env` :
```
FIREBASE_API_KEY=your_api_key
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_storage_bucket
```

2. Charger dans main.dart :
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
```

---

## 📞 Support

Pour des questions sur l'intégration :
- Vérifier la documentation principal : `RESERVATION_SYSTEM_DOC.md`
- Consulter les modèles dans `lib/models/`
- Voir les exemples dans `lib/screens/`

---

**Bonne intégration! 🎉**
