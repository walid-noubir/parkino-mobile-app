# 🔒 Système de Réservation Unique par Utilisateur

## 📋 Vue d'ensemble

Chaque utilisateur ne peut avoir qu'une seule réservation active à la fois. Si un utilisateur a réservé la place n°2, il ne peut pas réserver la place n°3 tant que sa première réservation n'a pas expiré ou n'a pas été annulée.

## ✨ Fonctionnalités

1. **Vérification automatique** : Avant de permettre une réservation, le système vérifie que l'utilisateur n'a pas d'autre réservation active
2. **Message d'erreur informatif** : Si l'utilisateur tente de réserver alors qu'il a déjà une réservation, il reçoit un message clair
3. **Affichage de la réservation existante** : Affiche la place et le code de la réservation existante
4. **Annulation facile** : L'utilisateur peut annuler sa réservation existante pour en créer une nouvelle
5. **Widget de garde** : `UniqueReservationGuard` pour afficher un avertissement visuel

## 📁 Fichiers modifiés/créés

### Modifiés
- **`lib/services/slot_reservation_service.dart`**
  - Ajout de `getUserActiveReservations(userId)`
  - Ajout de `hasActiveReservation(userId)`
  - Ajout de `getUserActiveReservation(userId)`
  - Modification de `reserveSlot()` : Ajoute une vérification au début

- **`lib/providers/slot_reservation_provider.dart`**
  - Ajout de `hasActiveReservation(userId)`
  - Ajout de `getUserActiveReservation(userId)`
  - Ajout de `getUserActiveReservations(userId)`

### Créés
- **`lib/widgets/unique_reservation_guard_widget.dart`**
  - `UniqueReservationGuard` : Widget pour afficher l'avertissement

## 🔄 Flux de fonctionnement

### Scénario 1: Utilisateur sans réservation

```
User clique sur "Réserver place n°2"
         ↓
Provider.reserveSlot() appelé
         ↓
Service vérifie: hasActiveReservation(userId)?
         ↓
AUCUNE réservation existante 
         ↓
Réservation créée
Notification affichée
Compteur démarre
```

### Scénario 2: Utilisateur avec réservation

```
User clique sur "Réserver place n°3"
User a déjà une réservation (place n°2)
         ↓
Provider.reserveSlot() appelé
         ↓
Service vérifie: hasActiveReservation(userId)?
         ↓
RÉSERVATION EXISTANTE TROUVÉE 
         ↓
Exception lancée:
"Vous avez déjà une réservation active (Place #2).
 Vous ne pouvez réserver qu'une seule place à la fois."
         ↓
Message d'erreur affiché à l'utilisateur
         ↓
Utilisateur peut:
  a) Attendre l'expiration (5 min)
  b) Annuler sa réservation existante
```

## 🎨 Message d'erreur affiché

```
┌─────────────────────────────────────┐
│ ⚠️  Réservation active              │
│ Vous avez une réservation en cours  │
├─────────────────────────────────────┤
│ Place n°2          Code: 1234       │
│                                      │
│ Vous ne pouvez réserver qu'une      │
│ seule place à la fois.              │
│ Veuillez attendre l'expiration ou   │
│ annuler cette réservation.          │
├─────────────────────────────────────┤
│ [Annuler cette réservation]         │
└─────────────────────────────────────┘
```

## 💻 Exemple d'utilisation du widget

### Option 1: Affichage du widget de garde

```dart
// Dans votre écran de réservation
UniqueReservationGuard(
  userId: currentUser.id,
  activeReservationChild: YourReservationForm(),
  onReservationCancelled: () {
    // L'utilisateur a annulé sa réservation
    // Vous pouvez rafraîchir l'écran
  },
)
```

### Option 2: Vérification manuelle

```dart
// Vérifier si l'utilisateur a une réservation
final hasReservation = await provider.hasActiveReservation(userId);
if (hasReservation) {
  final reservation = await provider.getUserActiveReservation(userId);
  print('Utilisateur a déjà réservé: Place #${reservation.slotNumber}');
} else {
  // Permettre la réservation
}
```

## 🔍 Code source: Vérification

### Dans le Service

```dart
Future<bool> hasActiveReservation(String userId) async {
  final reservations = await getUserActiveReservations(userId);
  return reservations.isNotEmpty;
}

Future<SlotReservation?> getUserActiveReservation(String userId) async {
  final reservations = await getUserActiveReservations(userId);
  if (reservations.isEmpty) return null;
  return reservations.first;
}
```

### Dans reserveSlot()

```dart
Future<SlotReservation> reserveSlot({...}) async {
  //  Vérification AVANT la réservation
  final hasActive = await hasActiveReservation(userId);
  if (hasActive) {
    final existing = await getUserActiveReservation(userId);
    throw Exception(
      'Vous avez déjà une réservation active (Place #${existing?.slotNumber}).\n'
      'Vous ne pouvez réserver qu\'une seule place à la fois.'
    );
  }
  
  // Continuer avec la réservation...
}
```

## 🧪 Tests

### Test 1: Vérifier qu'on ne peut pas réserver deux fois

```dart
1. Réserver place n°2 (succès)
2. Tenter de réserver place n°3 (error: déjà une réservation)
3. Vérifier le message d'erreur
```

### Test 2: Vérifier qu'on peut réserver après annulation

```dart
1. Réserver place n°2 (succès)
2. Annuler la réservation (succès)
3. Réserver place n°3 (succès)
```

### Test 3: Vérifier qu'on peut réserver après expiration

```dart
1. Réserver place n°2 à 14:30 (succès)
2. Tenter de réserver place n°3 à 14:30 (échec)
3. Attendre 5 minutes (14:35)
4. Réserver place n°3 à 14:35 (succès - l'ancienne a expiré)
```

## 📊 Architecture

```
SlotReservationService
├── hasActiveReservation(userId: String): Future<bool>
├── getUserActiveReservation(userId: String): Future<SlotReservation?>
├── getUserActiveReservations(userId: String): Future<List<SlotReservation>>
└── reserveSlot(...)
    └── Vérifie hasActiveReservation() AVANT de réserver

SlotReservationProvider
├── hasActiveReservation(userId: String)
├── getUserActiveReservation(userId: String)
├── getUserActiveReservations(userId: String)
└── reserveSlot(...)

UniqueReservationGuard (Widget)
└── Affiche avertissement si hasActiveReservation()
```

## 🎯 Cas d'usage

###  Autorisé
- User A réserve place 1 → OK
- User A attend 5 min → Réservation expire automatiquement
- User A réserve place 2 → OK (nouvelle réservation)

###  Rejeté
- User A réserve place 1 → OK
- User A tente de réserver place 2 tout de suite → ERREUR
- User A doit attendre ou annuler la place 1

###  Autorisé (après annulation)
- User A réserve place 1 → OK
- User A annule → OK
- User A réserve place 2 → OK (nouveau)

## 🚀 Intégration

Aucune intégration supplémentaire n'est nécessaire. Le système fonctionne automatiquement:

1.  Le service vérifie automatiquement avant de réserver
2.  L'exception est lancée automatiquement
3.  Le provider la capture et l'affiche dans `_error`
4.  Votre UI affiche le message d'erreur

## 📝 Notes

- Les réservations expirées passent automatiquement à "expired"
- La vérification se fait en temps réel (Firestore query)
- Aucune limite programmatique pour les administrateurs (ils pourraient réserver plusieurs si nécessaire)
- Le widget `UniqueReservationGuard` est optionnel (pour une meilleure UX)

## 🔄 Flux Firestore

```
parkings/main_parking/floors/etage_2/slots/{slotId}/slot_reservations/{resId}
  ├── status: "active" | "expired" | "used"
  ├── userId: "user_id"
  ├── slotNumber: 2
  ├── code: "1234"
  ├── expiresAt: DateTime
  └── ...
```

La vérification cherche tous les documents WHERE userId = "xxx" AND status = "active"

Prêt à l'emploi! 🎉
