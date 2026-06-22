# Quick Start - Démarrage rapide

## 🚀 Lancer l'application en 3 étapes

### Étape 1: Mettre à jour `main.dart`

Remplacez le contenu de `lib/main.dart` par:

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
        home: const ParkingReservationHub(),
      ),
    );
  }
}
```

### Étape 2: Installer les dépendances

```bash
flutter pub get
```

### Étape 3: Lancer l'application

```bash
flutter run
```

---

## 🧪 Scénarios de test

###  Réservation réussie

1. **Accueil** → "Réserver une place"
2. Sélectionner **B1**, durée **2h** → "Continuer"
3. Remplir le formulaire:
   - Numéro: `4242424242424242`
   - Titulaire: `JEAN DUPONT`
   - Date: `12/25`
   - CVV: `123`
4. Cliquer **"Payer maintenant"**
5.  Voir le QR code de confirmation

---

###  Paiement refusé

1. **Accueil** → "Réserver une place"
2. Sélectionner **B2**, durée **1h** → "Continuer"
3. Remplir avec:
   - Numéro: `4000000000000000` (carte refusée)
   - Autres champs: valides
4. Cliquer **"Payer maintenant"**
5.  Voir message d'erreur "Carte déclinée"

---

### 🔍 Voir mes réservations

1. **Accueil** → "Mes réservations"
2. Voir la liste de vos réservations
3. Cliquer pour voir le QR code

---

### ✓ Valider un QR code

1. **Accueil** → "Valider QR Code"
2. **"Copier"** une réservation depuis la liste
3. Coller dans le champ
4. Cliquer **"Valider le QR Code"**
5. Voir le résultat de validation

---

## 📱 État de l'application

### Écran d'accueil (Hub)
```
┌─────────────────────────────┐
│   🅿️ Parkino               │
│   Système de réservation    │
│   3 place(s) disponible(s)  │
└─────────────────────────────┘
│                             │
│  [Réserver une place]       │
│  [Mes réservations]         │
│  [Valider QR Code]          │
│                             │
│  📝 À propos                │
│  💳 Cartes de test          │
└─────────────────────────────┘
```

### Écran de réservation
```
Sélectionner une place:
[B1] [B2] [B3]

Durée (heures):
[1h] [2h] [3h] [4h] [8h] [12h] [24h]

Montant total: 10.00 MAD

[Continuer vers le paiement]
```

### Écran de paiement
```
Résumé:
Place: B1
Durée: 2h
Total: 10.00 MAD

Informations de paiement:
[Numéro de carte]
[Nom du titulaire]
[Date] [CVV]

Cartes de test:
✓ 4242424242424242
✗ 4000000000000000

[Payer maintenant] [Annuler]
```

### Écran de confirmation
```
✓ Réservation confirmée!

Détails:
ID: abc123def456
Place: B1
Montant: 10.00 MAD
Statut: confirmed

┌─────────────────┐
│   [QR Code]     │
└─────────────────┘

Informations:
• QR code utilisable une seule fois
• Expire dans 15 minutes si non utilisé
• Assurez-vous d'être sur place

[Retour à l'accueil]
```

---

## 📊 Volume de test

### Tester la limite de places

1. Faire 3 réservations (B1, B2, B3)
2. Essayer de réserver une 4e place
3.  Voir "Place non disponible"

---

### Tester l'expiration

1. Créer une réservation (ne pas payer)
2. Attendre 15 minutes
3.  Voir le statut change à "expired"

---

## 🔧 Dépannage

### L'application ne démarre pas?

```bash
# Nettoyer le cache
flutter clean
flutter pub get
flutter run
```

### Les providers n'existent pas?

Vérifier que `main.dart` utilise `MultiProvider` avec les 3 providers :
```dart
providers: [
  ChangeNotifierProvider(create: (_) => ReservationProvider()),
  ChangeNotifierProvider(create: (_) => PaymentProvider()),
  ChangeNotifierProvider(create: (_) => QRCodeProvider()),
],
```

### Les modèles ne font pas la compilation?

Vérifier l'importation dans `main.dart`:
```dart
import 'package:parkino/providers/index.dart';
import 'package:parkino/screens/parking_reservation_hub.dart';
```

---

## 💡 Conseils

1. **Utiliser le même userId**: Toutes les réservations utilisent `user123`
2. **Paiement immédiat**: Le paiement est traité en 1.5 secondes
3. **QR code statique**: Peut être copié/collé pour test (pas besoin de scanner)
4. **Base de données**: Les données résident en mémoire (effacées au redémarrage)

---

## 📝 Prochaines étapes

- [ ] Ajouter authentification Firebase
- [ ] Intégrer Firestore pour persistance
- [ ] Ajouter scanner QR code caméra
- [ ] Ajouter notifications locales
- [ ] Ajouter historique paiement
- [ ] Ajouter support multi-étages

---

**Prêt à réserver! 🅿️**
