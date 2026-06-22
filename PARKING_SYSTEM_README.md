# 🅿️ Parkino - Système de Réservation de Parking

Un système complet de réservation de places de parking avec **paiement virtuel** et **génération de QR codes** pour Flutter. Conçu pour le 2e étage avec 3 places (B1, B2, B3).

---

## ✨ Fonctionnalités principales

 **Réservation** - Sélection de place et durée
 **Calcul automatique** - Prix 5 MAD/heure
 **Paiement virtuel** - Simulation avec cartes de test
 **QR Code unique** - Token sécurisé SHA256
 **Gestion des statuts** - pending_payment → confirmed → used/expired
 **Expiration** - Réservation 15 min, QR 60 min
 **Validation** - Complète avec messages d'erreur
 **UI moderne** - Material Design 3 avec animations

---

## 🚀 Démarrage rapide (3 étapes)

### 1️⃣ Installer les dépendances
```bash
flutter pub get
```

### 2️⃣ Mettre à jour `main.dart`
```dart
import 'package:parkino/providers/index.dart';
import 'package:parkino/screens/parking_reservation_hub.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => QRCodeProvider()),
      ],
      child: MaterialApp(
        home: const ParkingReservationHub(),
      ),
    );
  }
}
```

### 3️⃣ Lancer l'application
```bash
flutter run
```

---

## 💳 Cartes de test

###  Paiement accepté
```
Numéro: 4242424242424242
Date: 12/25
CVV: 123
Titulaire: JEAN DUPONT
```

###  Paiement refusé
```
Numéro: 4000000000000000
```

###  Autres cartes
```
Acceptées si tous les champs sont valides
```

---

## 📁 Structure du projet

```
lib/
├── models/              ← Modèles de données (4 fichiers)
├── services/            ← Logique métier (4 services)
├── providers/           ← Gestion d'état (3 providers)
└── screens/             ← Interface utilisateur (6 écrans)

Documentation/
├── RESERVATION_SYSTEM_DOC.md    ← Guide complet
├── INTEGRATION_GUIDE.md         ← Intégration
├── QUICKSTART.md                ← Démarrage rapide
├── ARCHITECTURE_DIAGRAM.md      ← Diagrammes
├── README_DOCS.md               ← Index documentation
└── VERIFICATION_CHECKLIST.md    ← Checklist
```

---

## 📚 Documentation

Pour chaque besoin, voici le document à consulter:

| Besoin | Document | Temps |
|--------|----------|-------|
| 🚀 Lancer rapidement | [QUICKSTART.md](QUICKSTART.md) | 5 min |
| 📖 Comprendre tout | [RESERVATION_SYSTEM_DOC.md](RESERVATION_SYSTEM_DOC.md) | 20 min |
| 🔧 Intégrer | [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md) | 15 min |
| 📊 Architecture | [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md) | 10 min |
| 🗺️ Naviguer docs | [README_DOCS.md](README_DOCS.md) | 5 min |
|  Vérifier tout | [VERIFICATION_CHECKLIST.md](VERIFICATION_CHECKLIST.md) | 5 min |

---

## 🎯 Scénario complet

### 📱 Écran d'accueil (Hub)
```
🅿️ Parkino
Système de réservation
3 place(s) disponible(s)

[Réserver une place]
[Mes réservations]
[Valider QR Code]

À propos | Cartes de test
```

### 🅿️ Écran de réservation
```
Choisir une place:
[B1] [B2] [B3]

Durée de réservation:
[1h] [2h] [3h] [4h] [8h] [12h] [24h]

Montant total: 10.00 MAD

[Continuer vers le paiement]
```

### 💳 Écran de paiement
```
Résumé:
Place: B1
Durée: 2h
Total: 10.00 MAD

[Numéro de carte]
[Nom du titulaire]
[Date] [CVV]

Cartes de test:
✓ 4242424242424242
✗ 4000000000000000

[Payer maintenant] [Annuler]
```

###  Écran de confirmation
```
✓ Réservation confirmée!

Détails:
ID: abc123def456
Place: B1
Montant: 10.00 MAD

[QR Code]

Informations importantes:
• QR utilisable une seule fois
• Expire dans 15 min si non utilisé

[Retour à l'accueil]
```

---

## 🔄 Flux de réservation

```
Sélection de place
        ↓
Sélection de durée
        ↓
Calcul de prix
        ↓
Formulaire paiement
        ↓
Validation des données
        ↓ SUCCESS         ↓ FAILURE
Générer QR code    Afficher erreur
        ↓               ↓
Confirmer      Annuler et retour
        ↓
Afficher QR code
        ↓
Fin réservation
```

---

## 🔐 Sécurité QR Code

### Génération
```
Algorithme: SHA256
Input: {reservationId}:{slot}:{timestamp}
Output: 32 caractères
Validation: Token + Slot + Expiration
```

### Utilisation
```
 Token valide
 Slot correspond
 Non expiré (60 min)
 Non déjà utilisé
```

---

## 📊 Données

### Réservations
```
ID
Place (B1, B2, B3)
Statut (pending_payment, confirmed, used, expired)
Prix (5 MAD × heures)
Durée (1-24h)
Dates de réservation
QR Code (JSON avec token)
```

### Paiements
```
ID
Statut (pending, successful, failed)
Montant
Date de traitement
Derniers 4 chiffres carte
Message d'erreur (si applicable)
```

---

## 🧪 Tests

### Test 1: Réservation réussie
1. Hub → "Réserver une place"
2. Sélectionner B1, durée 2h
3. Remplir avec 4242424242424242
4.  Voir QR code

### Test 2: Paiement refusé
1. Hub → "Réserver une place"
2. Sélectionner B2, durée 1h
3. Remplir avec 4000000000000000
4.  Voir erreur "Carte déclinée"

### Test 3: Limites de places
1. Réserver B1, B2, B3 (succès)
2. Essayer réserver B1 à nouveau
3.  Voir "Place non disponible"

### Test 4: Voir réservations
1. Créer une réservation
2. Hub → "Mes réservations"
3.  Voir la réservation avec QR code

### Test 5: Valider QR
1. Créer et payer une réservation
2. Hub → "Valider QR Code"
3. Copier puis coller le QR code
4.  Voir validation réussie

---

## 🛠️ Architecture

### Modèles
- `ParkingSlot` - Places disponibles
- `Reservation` - Réservations avec statuts
- `Payment` - Transactions paiement
- `QRCodeData` - Données QR avec token

### Services
- `PaymentService` - Paiement virtuel
- `ReservationService` - Gestion réservations
- `PaymentDatabaseService` - Stockage paiements
- `QRCodeService` - Gestion QR codes

### Providers
- `ReservationProvider` - État réservations
- `PaymentProvider` - État paiements
- `QRCodeProvider` - État QR codes

### Écrans
- `ParkingReservationHub` - Accueil
- `SecondFloorReservationScreen` - Sélection
- `PaymentScreen` - Paiement
- `ConfirmationScreen` - Confirmation
- `ReservationManagementScreen` - Gestion
- `QRCodeValidationScreen` - Validation

---

## 📦 Dépendances

```yaml
provider: ^6.0.0          # Gestion d'état
qr_flutter: ^4.0.0        # Génération QR
uuid: ^4.0.0              # IDs uniques
crypto: ^3.0.3            # SHA256 tokens
firebase_core: ^4.4.0     # Firebase (optionnel)
cloud_firestore: ^6.1.2   # Firestore (optionnel)
```

---

## 🔧 Configuration

### Insérer dans main.dart
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ReservationProvider()),
    ChangeNotifierProvider(create: (_) => PaymentProvider()),
    ChangeNotifierProvider(create: (_) => QRCodeProvider()),
  ],
  child: MaterialApp(
    home: const ParkingReservationHub(),
  ),
)
```

### Ajouter à pubspec.yaml
```yaml
dependencies:
  qr_flutter: ^4.0.0
  uuid: ^4.0.0
  crypto: ^3.0.3
```

---

## 🚀 Prochaines étapes

### Court terme
- [ ] Tester tous les scénarios
- [ ] Intégrer dans le projet
- [ ] Ajouter authentification

### Moyen terme
- [ ] Support Firestore
- [ ] Scanner QR caméra
- [ ] Notifications
- [ ] Historique utilisateur

### Long terme
- [ ] Multi-étages
- [ ] Réservations récurrentes
- [ ] Paiement réel (Stripe/PayPal)
- [ ] Admin dashboard

---

## 🎓 Apprentissage

### Fichiers à lire par ordre
1. **QUICKSTART.md** (5 min) - Démarrage
2. **ARCHITECTURE_DIAGRAM.md** (10 min) - Vue d'ensemble
3. **RESERVATION_SYSTEM_DOC.md** (20 min) - Détails complets
4. **INTEGRATION_GUIDE.md** (15 min) - Intégration avancée

### Ensuite explorer
- Les modèles dans `lib/models/`
- Les services dans `lib/services/`
- Les providers dans `lib/providers/`
- Les écrans dans `lib/screens/`

---

## ❓ FAQ

**Q: Comment ajouter des places?**
A: Modifier `initializeSlots()` dans ReservationService

**Q: Comment changer le prix?**
A: Modifier `pricePerHour` dans PaymentService

**Q: Comment intégrer Firestore?**
A: Voir INTEGRATION_GUIDE.md section "Configuration Firestore"

**Q: Comment scanner avec caméra?**
A: Voir INTEGRATION_GUIDE.md section "Scanner QR code"

**Q: Comment ajouter l'authentification?**
A: Voir INTEGRATION_GUIDE.md section "Authentification utilisateur"

---

## 📞 Support

### Problèmes courants
- App ne compile pas? → Exécuter `flutter clean && flutter pub get`
- Providers non trouvés? → Vérifier les imports dans main.dart
- QR code vide? → Vérifier les données du QR code

### Documentation
- Architecture: [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)
- Intégration: [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
- Démarrage: [QUICKSTART.md](QUICKSTART.md)
- Complet: [RESERVATION_SYSTEM_DOC.md](RESERVATION_SYSTEM_DOC.md)

---

## 📊 État du projet

| Élément | Statut | Notes |
|---------|--------|-------|
| Modèles |  | 4 complets |
| Services |  | 4 complets |
| Providers |  | 3 complets |
| Écrans |  | 6 complets |
| Documentation |  | 6 fichiers |
| Tests | 🟡 | Manuels uniquement |
| Déploiement | 🟡 | Prêt à intégrer |

---

## 📝 License

Ce projet est fourni tel quel pour la réservation de parking.

---

##  Checklist de démarrage

- [ ] `flutter pub get` exécuté
- [ ] main.dart intègre les providers
- [ ] `flutter run` sans erreur
- [ ] Test rapide de réservation réussie
- [ ] Test rapide de paiement refusé
- [ ] QUICKSTART.md lu
- [ ] Prêt à l'emploi!

---

## 🎉 Vous êtes prêt!

L'implémentation est **complète et prête à l'emploi**. 

➡️ **Commencer par**: [QUICKSTART.md](QUICKSTART.md)

➡️ **Besoin d'aide?**: [README_DOCS.md](README_DOCS.md)

➡️ **Vue d'ensemble**: [ARCHITECTURE_DIAGRAM.md](ARCHITECTURE_DIAGRAM.md)

---

**Bon développement! 🚀**
