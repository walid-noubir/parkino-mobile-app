# 🚀 Quick Start - Réservation Unique

## 5 minutes pour implémenter

### 1️⃣ Vérification automatique (déjà activée)

Le système vérifie **automatiquement** dans `reserveSlot()`:

```dart
// Dans slot_reservation_service.dart (DÉJÀ FAIT)
final hasActive = await hasActiveReservation(userId);
if (hasActive) {
  throw Exception('Vous avez déjà une réservation active...');
}
```

### 2️⃣ Afficher l'erreur (3 options)

#### Option A: Message d'erreur simple (+ facile)

```dart
try {
  await provider.reserveSlot(...);
  // Succès
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(' ${e.toString()}'))
  );
}
```

#### Option B: Dialog d'erreur (+ informatif)

```dart
try {
  await provider.reserveSlot(...);
} catch (e) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(' Réservation impossible'),
      content: Text(e.toString()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
```

#### Option C: Widget de garde (+ beau)

```dart
UniqueReservationGuard(
  userId: currentUser.id,
  activeReservationChild: MyReservationForm(),
  onReservationCancelled: () {
    // Rafraîchir l'écran
  },
)
```

### 3️⃣ Exemple complet

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkino/providers/slot_reservation_provider.dart';
import 'package:parkino/widgets/unique_reservation_guard_widget.dart';

class MyReservationScreen extends StatelessWidget {
  final String userId;

  const MyReservationScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réserver une place')),
      body: UniqueReservationGuard(
        userId: userId,
        activeReservationChild: _buildReservationForm(context),
        onReservationCancelled: () {
          // L'utilisateur a annulé sa réservation
          // Rafraîchir ou montrer un message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Réservation annulée ')),
          );
        },
      ),
    );
  }

  Widget _buildReservationForm(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Vos boutons de réservation
        ElevatedButton(
          onPressed: () => _reserveSlot(context, 'slot_1', 1),
          child: const Text('Place n°1'),
        ),
        ElevatedButton(
          onPressed: () => _reserveSlot(context, 'slot_2', 2),
          child: const Text('Place n°2'),
        ),
        ElevatedButton(
          onPressed: () => _reserveSlot(context, 'slot_3', 3),
          child: const Text('Place n°3'),
        ),
      ],
    );
  }

  void _reserveSlot(
    BuildContext context,
    String slotId,
    int slotNumber,
  ) async {
    try {
      final provider = context.read<SlotReservationProvider>();
      
      await provider.reserveSlot(
        slotId: slotId,
        slotNumber: slotNumber,
        userId: userId,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' Place n°$slotNumber réservée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Afficher le message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
```

## 🎯 Ce qui se passe

### Cas 1: Sans réservation
```
User click "Réserver place 2"
         ↓
hasActiveReservation(userId) → false
         ↓
 Réservation créée
```

### Cas 2: Avec réservation existante
```
User click "Réserver place 3"
         ↓
hasActiveReservation(userId) → true
         ↓
Exception lancée avec le message:
"Vous avez déjà une réservation active (Place #2).
 Vous ne pouvez réserver qu'une seule place à la fois."
         ↓
 Snackbar/Dialog affiche le message
```

## 📱 Visuel du widget de garde

```
┌──────────────────────────────────┐
│ ⚠️  Réservation active            │
│ Vous avez une réservation en cours│
├──────────────────────────────────┤
│ Place n°2              Code: 1234 │
│ 🕐 Temps restant: 03:45           │
├──────────────────────────────────┤
│ [Annuler cette réservation]       │
└──────────────────────────────────┘
```

##  Checklist d'implémentation

- [x] Service vérifie automatiquement
- [x] Exception lancée si réservation existante
- [x] Provider expose les méthodes
- [x] Widget de garde créé
- [ ] Intégrer le widget dans votre écran
- [ ] Tester: réserver 1x puis tenter 2x
- [ ] Vérifier le message d'erreur
- [ ] Vérifier l'annulation de réservation

## 🧪 Test rapide

```bash
1. flutter run
2. Se connecter
3. Réserver place 1 →  Succès
4. Tenter de réserver place 2 →  Message d'erreur
5. Vérifier le message: "Vous avez déjà une réservation active..."
6. Cliquer sur "Annuler cette réservation" → 
7. Réserver place 2 →  Succès (après annulation)
```

## 🎁 Bonus: Afficher la réservation existante

```dart
// Afficher le compteur de la réservation existante
final reservation = await provider.getUserActiveReservation(userId);
if (reservation != null) {
  print('Place: #${reservation.slotNumber}');
  print('Code: ${reservation.code}');
  print('Expire: ${reservation.expiresAt}');
}
```

## 🚀 C'est prêt!

Le système est complètement en place:
-  Vérification automatique
-  Erreur lancée automatiquement
-  Widget de garde optionnel
-  Documentation complète

Intégrez le widget ou utilisez les méthodes du provider! 🎉
