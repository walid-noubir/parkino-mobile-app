# Architecture du Système de Réservation

## 📊 Diagramme d'architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         ÉCRANS (UI)                              │
├─────────────────────────────────────────────────────────────────┤
│                    ParkingReservationHub                          │
│                    (Écran d'accueil)                              │
│                          ↓↓↓                                      │
│         ┌──────────────┬────────────────┬──────────────┐         │
│         ↓              ↓                ↓              ↓          │
│    Selection      PaymentScreen    ReservationMgmt  QRValidation│
│    Screen         (Paiement)           Screen          Screen    │
│         ↓              ↓                │              ↓          │
│         └──→ ConfirmationScreen ←──────┘              │          │
│                (Confirmation + QR)        ←───────────┘         │
└─────────────────────────────────────────────────────────────────┘
                              ↑↑↑
        ┌─────────────────────┼────────────────────┐
        │                     │                    │
┌───────┴─────────┐  ┌────────┴──────────┐  ┌─────┴──────────┐
│   PROVIDERS     │  │   SERVICES        │  │   MODELS       │
├─────────────────┤  ├───────────────────┤  ├────────────────┤
│ Reservation     │  │ Reservation       │  │ ParkingSlot    │
│ Provider        │→ │ Service           │→ │ Reservation    │
│                 │  │                   │  │ Payment        │
├─────────────────┤  ├───────────────────┤  │ QRCodeData     │
│ Payment         │  │ Payment           │  └────────────────┘
│ Provider        │→ │ Service           │
│                 │  │                   │
├─────────────────┤  ├───────────────────┤
│ QRCode          │  │ PaymentDB         │
│ Provider        │→ │ Service           │
│                 │  │                   │
│ (ChangeNotifier)│  ├───────────────────┤
│                 │  │ QRCode            │
│                 │  │ Service           │
│                 │  │                   │
│                 │  │ (In-Memory DB)    │
└─────────────────┘  └───────────────────┘
```

---

## 🔄 Flux de paiement complet

```
START
  ↓
┌─────────────────────────────────┐
│ SelectionScreen                 │
│ - Place: B1, B2, B3             │
│ - Duration: 1-24h               │
│ - Price: duration × 5 MAD       │
└──────────┬──────────────────────┘
           │ "Continuer vers paiement"
           ↓
┌─────────────────────────────────┐
│ ReservationProvider             │
│ .createReservation()            │
│ Status: pending_payment         │
│ Slot marked unavailable         │
└──────────┬──────────────────────┘
           │
           ↓
┌─────────────────────────────────┐
│ PaymentScreen                   │
│ - Card form                     │
│ - Validation                    │
│ - Test cards displayed          │
└──────────┬──────────────────────┘
           │ "Payer maintenant"
           ↓
┌─────────────────────────────────┐
│ PaymentProvider.processPayment()│
│ - Validate card data            │
│ - Send to PaymentService        │
└──────────┬──────────────────────┘
           │
        ┌──┴────────────────────┐
        │                       │
        ↓ SUCCESS               ↓ FAILURE
┌────────────────────┐  ┌─────────────────┐
│ Payment successful │  │ Payment failed  │
│ Status: successful │  │ Error message   │
└────────┬───────────┘  └────────┬────────┘
         │                       │
         ↓                       ↓
┌─────────────────────────┐  ┌──────────────┐
│ QRCodeProvider          │  │ Cancel res.  │
│ .generateQRCode()       │  │ Slot free    │
│ - Unique token          │  │ Return to    │
│ - SHA256 hash           │  │ payment form │
│ - 60min expiry          │  └──────────────┘
└────────┬────────────────┘
         │
         ↓
┌─────────────────────────────┐
│ ReservationProvider         │
│ .confirmReservation()       │
│ Status: confirmed           │
│ QRCode stored               │
└────────┬────────────────────┘
         │
         ↓
┌─────────────────────────────┐ 
│ ConfirmationScreen          │
│ - Display QR code           │
│ - Show reservation details  │
│ - 15min expiration warning  │
└────────┬────────────────────┘
         │
         ↓
        END
```

---

## 💾 Schéma de base de données

### Réservations Collection
```
reservations/
  └── {id}/
       ├── id: String
       ├── slotId: String (B1, B2, B3)
       ├── floor: Int (2)
       ├── userId: String
       ├── status: String (pending_payment|confirmed|used|expired)
       ├── price: Double (5.0 × hours)
       ├── durationHours: Int
       ├── createdAt: DateTime
       ├── expiresAt: DateTime (createdAt + 15min)
       ├── reservationStart: DateTime
       ├── reservationEnd: DateTime
       ├── paymentId: String?
       ├── qrCode: String? (JSON)
       └── qrCodeUsed: Boolean
```

### Payments Collection
```
payments/
  └── {id}/
       ├── id: String
       ├── reservationId: String
       ├── userId: String
       ├── amount: Double
       ├── status: String (pending|successful|failed|cancelled)
       ├── method: String (credit_card)
       ├── cardLastDigits: String (last 4)
       ├── createdAt: DateTime
       ├── processedAt: DateTime?
       └── errorMessage: String?
```

### QR Codes Data (stored in Reservation.qrCode)
```
{
  "reservationId": "uuid",
  "slot": "B1",
  "securityToken": "sha256_hash_32chars",
  "generatedAt": "2024-12-01T10:00:00.000Z",
  "expiresAt": "2024-12-01T11:00:00.000Z"
}
```

---

## 📋 Validation des données

### Carte de crédit
```
Field      Format           Example
────────────────────────────────────
Number     16 digits        4242 4242 4242 4242
Expiry     MM/YY            12/25
CVV        3-4 digits       123
Holder     Text             JEAN DUPONT
```

### Réservation
```
Field          Min    Max    Required
─────────────────────────────────────
Slot          B1-B3   -      Yes
Duration      1h     24h     Yes
Price         5 MAD  120 MAD Auto (5×N)
UserId        1 char  -      Yes
```

---

## ⏱️ Timeline d'expiration

```
T=0         Réservation créée (status: pending_payment)
            Slot marqué non disponible
            
T=0+1.5s    Paiement traité
            Si succès: QR généré, Réservation confirmée
            Si échec: Réservation annulée, Slot libéré

T=0+15min   Réservation expire (status: expired)
            Slot libéré automatiquement
            
QR Code:
T=0         QR généré (60min validity)
T=0+60min   QR expiré (non utilisable)

Validation:
- À chaque présentation du QR code
- Rejet si expiré
- Marqué comme utilisé après tête
```

---

## 🔐 Sécurité

### Token QR Code
```
Algorithm: SHA256
Input:     {reservationId}:{slot}:{timestamp}
Output:    First 32 characters of hash
Validation: Token must match + slot must match + not expired
```

### Numéro de carte
```
Storage:   Dernier 4 chiffres seulement
Validation: Format 16 chiffres
Test Mode: Cartes de test prédéfinies
```

---

## 🎯 Points d'intégration

### Firestore (futur)
```dart
// Remplacer avec:
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
await _firestore.collection('reservations').doc(id).set(data);
```

### Firebase Auth
```dart
final user = FirebaseAuth.instance.currentUser;
final userId = user?.uid;
```

### Firebase Storage
```dart
// Pour stocker les QR codes en tant qu'images
final storageRef = FirebaseStorage.instance.ref('qrcodes/$id.png');
```

---

## 📱 Composants réutilisables

### Card Widget Pattern
```dart
Card(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column( /* contenu */ ),
  ),
)
```

### Status Color Map
```dart
pending_payment → Orange
confirmed       → Green
used            → Blue
expired         → Red
```

### Form Validation Pattern
```dart
TextFormField(
  validator: (value) {
    if (value?.isEmpty ?? true) return 'Requis';
    return null;
  },
)
```

---

**Document généré automatiquement** ✨
