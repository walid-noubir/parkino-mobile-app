# Système de Réservation de Parking avec Paiement Virtuel

## 📋 Vue d'ensemble

Cet système complet gère les réservations de places de parking au 2e étage avec paiement virtuel et génération de QR codes. Il est développé en **Flutter** avec une architecture modulaire basée sur des services et des providers.

---

## 🏗️ Architecture

### Structure des fichiers

```
lib/
├── models/
│   ├── parking_slot.dart           # Modèle des places
│   ├── reservation.dart             # Modèle des réservations
│   ├── payment.dart                 # Modèle des paiements
│   ├── qr_code_data.dart           # Modèle des données QR
│   └── index.dart                  # Export centralisé
├── services/
│   ├── payment_service.dart        # Service de paiement virtuel
│   ├── reservation_service.dart    # Service de réservation
│   ├── payment_database_service.dart # Base de données paiements
│   ├── qr_code_service.dart        # Service QR code
│   └── index.dart                  # Export centralisé
├── providers/
│   ├── reservation_provider.dart   # Provider réservation
│   ├── payment_provider.dart       # Provider paiement
│   ├── qr_code_provider.dart      # Provider QR code
│   └── index.dart                  # Export centralisé
├── screens/
│   ├── parking_reservation_hub.dart    # Écran d'accueil
│   ├── second_floor_reservation_screen.dart  # Sélection place/durée
│   ├── payment_screen.dart          # Écran de paiement
│   ├── confirmation_screen.dart     # Confirmation avec QR code
│   ├── reservation_management_screen.dart    # Gestion réservations
│   ├── qr_code_validation_screen.dart       # Validation QR code
│   └── index.dart                   # Export centralisé
└── main.dart                        # Point d'entrée

```

---

## 🔋 Composants principaux

### 1. **Modèles de données** (`lib/models/`)

#### `ParkingSlot`
- Représente une place disponible (B1, B2, B3 au 2e étage)
- Propriétés: `id`, `floor`, `isAvailable`

#### `Reservation`
- Gère la réservation complète
- Statuts: `pending_payment`, `confirmed`, `used`, `expired`
- Propriétés: `id`, `slotId`, `durationHours`, `price`, `status`, `qrCode`, etc.

#### `Payment`
- Représente une transaction
- Statuts: `pending`, `successful`, `failed`, `cancelled`
- Propriétés: `id`, `amount`, `cardLastDigits`, `status`, etc.

#### `QRCodeData`
- Données contenues dans le QR code
- Contient: `reservationId`, `slot`, `securityToken`, `generatedAt`, `expiresAt`
- Génère un token sécurisé unique via SHA256

---

### 2. **Services métier** (`lib/services/`)

#### `PaymentService`
Logique de paiement virtuel simulé :
- **Carte acceptée**: `4242424242424242` →  Paiement réussi
- **Carte rejetée**: `4000000000000000` →  Paiement échoué
- **Autres nombres**:  Acceptées si tous les champs sont valides

Validations :
- Numéro: 16 chiffres
- Date: Format MM/YY
- CVV: 3-4 chiffres
- Nom: Non vide

#### `ReservationService`
- Création de réservations avec statut `pending_payment`
- Places disponibles au 2e étage: B1, B2, B3
- Confirmation de réservation avec QR code
- Gestion de l'expiration (15 minutes si non utilisée)
- Mise à jour de la disponibilité des places

#### `PaymentDatabaseService`
- Stockage des paiements en mémoire
- CRUD des paiements
- Historique des transactions
- Statistiques de paiement

#### `QRCodeService`
- Génération de QR codes uniques
- Validation des QR codes avec token sécurisé
- Marquage des QR codes comme utilisés
- Gestion de l'expiration QR (60 minutes)

---

### 3. **Providers** (`lib/providers/`)

#### `ReservationProvider`
- Gère l'état des réservations
- Expose les places disponibles
- Crée et confirme les réservations

#### `PaymentProvider`
- Gère l'état des paiements
- Traite les paiements asynchrones
- Calcule les prix
- Stocke les messages d'erreur

#### `QRCodeProvider`
- Gère l'état des QR codes
- Génère et valide les QR codes

---

### 4. **Écrans** (`lib/screens/`)

#### `ParkingReservationHub`
Écran d'accueil centralisant l'accès à :
- Réserver une place
- Voir ses réservations
- Valider un QR code

#### `SecondFloorReservationScreen`
Écran de sélection :
- Affiche les 3 places (B1, B2, B3)
- Sélection de la durée (1-24h)
- Calcul automatique du prix (5 MAD/h)
- Création de la réservation

#### `PaymentScreen`
Écran de paiement :
- Formulaire de carte de crédit
- Résumé de la réservation
- Traitement du paiement
- Messages d'erreur si refus
- Cartes de test affichées

#### `ConfirmationScreen`
Écran de succès :
- Affichage du QR code unique
- Détails de la réservation
- Informations importantes (expiration, QR code utilisable une fois)

#### `ReservationManagementScreen`
Gestion des réservations :
- Liste des réservations de l'utilisateur
- Affichage des QR codes valides
- Statut et temps d'expiration
- Classement par statut

#### `QRCodeValidationScreen`
Validation des QR codes :
- Saisie/Copie du contenu QR
- Validation du token sécurisé
- Marquage comme "utilisé"
- Liste des réservations actives

---

## 🔄 Flux de réservation

### 1. **Création de réservation**
```
SelectSlot + Duration → CreateReservation (pending_payment)
```

### 2. **Paiement**
```
PaymentForm → ValidateCardData → ProcessPayment
```

### 3. **Succès du paiement**
```
Payment Success → GenerateQRCode → ConfirmReservation (confirmed)
```

### 4. **Échec du paiement**
```
Payment Failed → DisplayError → CancelReservation
```

### 5. **Utilisation**
```
ValidateQRCode → MarkAsUsed (used)
```

### 6. **Expiration**
```
15 min without usage → Expire (expired)
```

---

## 💳 Logique de paiement

### Règles de validation

| Condition | Résultat | Code |
|-----------|----------|------|
| Numéro = 4242424242424242 |  Accepté | SUCCESS |
| Numéro = 4000000000000000 |  Rejeté | DECLINED |
| Tous les champs valides |  Accepté | SUCCESS |
| Champs invalides |  Rejeté | INVALID |

### Format des données de carte

- **Numéro**: 16 chiffres (ex: 4242 4242 4242 4242)
- **Date**: MM/YY (ex: 12/25)
- **CVV**: 3-4 chiffres (ex: 123)
- **Titulaire**: Texte libre (ex: JEAN DUPONT)

---

## 🔐 Sécurité du QR code

### Génération du token

```dart
final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
final data = '$reservationId:$slot:$timestamp';
final token = sha256(data).substring(0, 32);
```

### Validation du QR code

-  Token valide
-  Slot correspond
-  Non expiré (60 minutes)
-  Non déjà utilisé

### Données contenues dans le QR code (JSON)

```json
{
  "reservationId": "uuid",
  "slot": "B1",
  "securityToken": "sha256_hash",
  "generatedAt": "2024-12-01T10:00:00.000Z",
  "expiresAt": "2024-12-01T11:00:00.000Z"
}
```

---

## ⏰ Gestion de l'expiration

### Réservation
- **Expiration**: 15 minutes après création
- **Condition**: Si statut = `pending_payment` et dépassée
- **Action**: Statut devient `expired` et place libérée

### QR code
- **Expiration**: 60 minutes après génération
- **Validation**: Vérifiée à chaque utilisation

---

## 🎯 Dépendances

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  qr_flutter: ^4.0.0
  uuid: ^4.0.0
  crypto: ^3.0.3
  intl: ^0.20.2
  firebase_core: ^4.4.0
  cloud_firestore: ^6.1.2
  firebase_auth: ^6.1.4
  firebase_storage: ^13.0.6
```

---

## 🧪 Guide de test

### Tester une réservation réussie

1. Ouvrir l'app
2. Cliquer sur "Réserver une place"
3. Sélectionner "B1", "B2" ou "B3"
4. Choisir une durée (ex: 1 heure)
5. Cliquer "Continuer vers le paiement"
6. Remplir le formulaire avec:
   - **Numéro**: 4242424242424242
   - **Date**: 12/25
   - **CVV**: 123
   - **Titulaire**: JEAN DUPONT
7. Cliquer "Payer maintenant"
8.  Voir l'écran de confirmation avec QR code

### Tester un paiement refusé

1. Même flux mais avec:
   - **Numéro**: 4000000000000000
2.  Voir le message d'erreur "Carte déclinée"

### Tester un QR code invalide

1. Aller à "Valider QR Code"
2. Coller un JSON invalide
3.  Voir le message d'erreur

---

## 📊 Données en base de données

### Réservations
```dart
{
  'id': 'uuid',
  'slotId': 'B1',
  'floor': 2,
  'userId': 'user123',
  'status': 'confirmed', // pending_payment, confirmed, used, expired
  'price': 5.0,
  'durationHours': 1,
  'createdAt': DateTime,
  'expiresAt': DateTime,
  'qrCode': 'JSON string',
  'qrCodeUsed': false
}
```

### Paiements
```dart
{
  'id': 'payment123',
  'reservationId': 'uuid',
  'userId': 'user123',
  'amount': 5.0,
  'status': 'successful', // pending, successful, failed, cancelled
  'method': 'credit_card',
  'cardLastDigits': '4242',
  'createdAt': DateTime,
  'processedAt': DateTime,
  'errorMessage': null
}
```

---

## 🚀 Utilisation dans main.dart

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
        home: const ParkingReservationHub(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
      ),
    );
  }
}
```

---

## ✨ Points clés à retenir

1. **Places**: B1, B2, B3 au 2e étage uniquement
2. **Prix**: Fixe à 5 MAD/heure
3. **Paiement**: Simulation avec règles spécifiques
4. **QR code**: Unique, sécurisé, utilisable une seule fois
5. **Expiration réservation**: 15 minutes
6. **Expiration QR**: 60 minutes
7. **Base de données**: En mémoire (peut être remplacée par Firestore)

---

## 📝 Exemple d'utilisation

```dart
// Créer une réservation
final reservation = reservationProvider.createReservation(
  slotId: 'B1',
  durationHours: 2,
  price: 10.0,
  userId: 'user123',
);

// Traiter un paiement
final paymentResult = await paymentProvider.processPayment(
  cardNumber: '4242424242424242',
  expiryDate: '12/25',
  cvv: '123',
  holderName: 'JEAN DUPONT',
  amount: 10.0,
  reservationId: reservation.id,
  userId: 'user123',
);

// Si succès, générer QR code
if (paymentResult['success']) {
  final qrCode = qrCodeProvider.generateQRCode(
    reservationId: reservation.id,
    slot: 'B1',
  );
  
  // Confirmer la réservation
  reservationProvider.confirmReservation(
    reservationId: reservation.id,
    paymentId: paymentResult['paymentId'],
    qrCodeData: qrCode.toJsonString(),
  );
}
```

---

## ❓ FAQ

**Q: Comment ajouter plus de places?**
A: Modifier `initializeSlots()` dans `ReservationService`

**Q: Comment changer le prix?**
A: Modifier `pricePerHour` dans `PaymentService`

**Q: Comment changer l'expiration?**
A: Modifier `expirationMinutes` dans `ReservationService` ou `QRCodeService`

**Q: Peut-on intégrer Firestore?**
A: Oui, remplacer les listes en mémoire par des appels Firestore

**Q: Comment générer de vrais QR codes depuis caméra?**
A: Ajouter le package `qr_code_scanner` et lire la caméra

---

**Développé avec Flutter 🚀**
