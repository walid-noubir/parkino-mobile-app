# 🎯 Guide d'Implémentation - Compteur Décroissant et Notifications

## Étapes d'implémentation

### 1. Vérifier les fichiers créés

```
lib/services/reservation_timer_service.dart
lib/providers/reservation_notification_provider.dart
lib/widgets/reservation_countdown_widget.dart
lib/main.dart (modifié)
lib/screens/home/home_screen.dart (modifié)
lib/screens/notifications/notifications_screen.dart (complètement refondu)
lib/providers/slot_reservation_provider.dart (modifié)
```

### 2. Vérifier les imports

Assurez-vous que tous les imports dans vos fichiers sont corrects:

**main.dart**:
```dart
import 'providers/reservation_notification_provider.dart';
```

**home_screen.dart**:
```dart
import '../../widgets/reservation_countdown_widget.dart';
```

**notifications_screen.dart**:
```dart
import '../../providers/reservation_notification_provider.dart';
```

### 3. Tester votre application

1. **Lancer l'app**:
   ```bash
   flutter run
   ```

2. **Réserver une place**:
   - Accédez au screen de réservation (scan QR ou direct)
   - Cliquez sur "Réserver"

3. **Vérifications**:
   - Un compteur `Réservation active | Place n°X | MM:SS` apparaît en haut du home screen
   - Une notification apparaît dans l'onglet "Notifications"
   - Le compteur décrémente toutes les secondes
   - Après 5 minutes, le compteur disparaît
   - Une notification "Réservation expirée" apparaît

## 🎨 Personnalisation

### Modifier la durée (5 minutes par défaut)

Dans `lib/providers/slot_reservation_provider.dart`:

```dart
// Cherchez cette ligne dans reserveSlot()
_notificationProvider!.addReservationNotification(
  title: 'Place réservée',
  spotNumber: slotNumber,
  code: reservation.code,
  reservationDuration: const Duration(minutes: 5), // ← Modifier ici
);
```

Exemples:
```dart
const Duration(minutes: 10),  // 10 minutes
const Duration(seconds: 30),  // 30 secondes (pour tester)
const Duration(minutes: 1),   // 1 minute
```

### Modifier les couleurs du compteur

Dans `lib/widgets/reservation_countdown_widget.dart`:

```dart
// Couleur du texte
color: ParkinoTheme.goldenYellow,  // ← Changer la couleur

// Couleur du background
decoration: BoxDecoration(
  color: ParkinoTheme.goldenYellow.withOpacity(0.15), // ← Changer
  border: Border.all(
    color: ParkinoTheme.goldenYellow, // ← Changer
    width: 1.5,
  ),
),
```

### Modifier la position du compteur

Dans `lib/screens/home/home_screen.dart`:

Le compteur est affiché avant le header. Pour le changer de position:

```dart
Column(
  children: [
    const ReservationCountdownTimer(), // ← Déplacer ici ou ailleurs
    _buildModernHeader(),
    ...
  ],
)
```

## 🔍 Debugging

Si le compteur n'apparaît pas:

1. **Vérifier que NotificationProvider est fourni**:
   ```dart
   // Dans main.dart, vérifier:
   ChangeNotifierProvider(create: (context) => NotificationProvider()),
   ```

2. **Vérifier que SlotReservationProvider a accès à NotificationProvider**:
   ```dart
   // Dans main.dart, vérifier que setNotificationProvider() est appelé
   ```

3. **Ajouter des logs**:
   ```dart
   // Dans reservation_notification_provider.dart
   print('🔔 Reservation notification added: $spotNumber');
   print('⏱️ Timer remaining: ${_activeTimer?.formattedTime}');
   ```

## 📋 Checklist d'implémentation

- [ ] Tous les fichiers créés sont présents
- [ ] Les imports dans main.dart sont corrects
- [ ] NotificationProvider est dans le MultiProvider
- [ ] SlotReservationProvider reçoit la référence à NotificationProvider
- [ ] ReservationCountdownTimer est importé dans home_screen.dart
- [ ] Le compteur s'affiche lors d'une réservation
- [ ] Les notifications apparaissent dans notifications_screen.dart
- [ ] Le compteur décrémente correctement
- [ ] La notification d'expiration apparaît après 5 minutes

## 🚀 Prochaines étapes (optionnelles)

1. **Ajouter des sons de notification** (package: audioplayers)
2. **Ajouter des vibrations** (package: vibration)
3. **Sauvegarder les réservations en pause** (pause le timer au exit)
4. **Expiration automatique Firestore** (Firebasefunction pour cleanup)
5. **Notification push** (firebase_messaging)

## 💡 Cas d'utilisation

### Scénario 1: Utilisateur réserve une place
```
User → Tape sur place → reserveSlot() 
→ Notification créée 
→ Timer démarre (5:00)
→ Compteur affiché en haut
→ Notification dans onglet Notifications
```

### Scénario 2: Utilisateur annule la réservation
```
User → Clique "Annuler" 
→ cancelReservation() 
→ Timer annulé 
→ Compteur disparaît
→ Notification reste (archived)
```

### Scénario 3: Timer expire
```
5 minutes passent
→ Timer.onExpired() 
→ Notification d'expiration créée
→ Compteur disparaît
→ "Réservation expirée" apparaît
```

## 📞 Besoin d'aide?

Si quelque chose ne fonctionne pas:

1. Vérifiez les logs console pour les messages d'erreur
2. Vérifiez que tous les fichiers sont importés correctement
3. Assurez-vous que NotificationProvider est dans le context
4. Redémarrez l'app (`flutter pub get` + `flutter run`)

## 🎓 Architecture visuelle

```
┌─────────────────────────────────────┐
│  HomeScreen                         │
├─────────────────────────────────────┤
│ ReservationCountdownTimer ← Consumer│
│ (watches NotificationProvider)      │
├─────────────────────────────────────┤
│ Place n°2 | 04:32               ← Voir en temps réel
│ (Pulse animation)                   │
├─────────────────────────────────────┤
│ MainParkingCard                     │
│ QuickStatsRow                       │
│ InfoCardsSection                    │
└─────────────────────────────────────┘

         NotificationProvider
              (Singleton)
         ┌─────────────────────┐
         │ _activeTimer        │ ← ReservationTimer
         │ _notifications[]    │ ← List<AppNotification>
         │ notifyListeners()   │ ← Trigger rebuilds
         └─────────────────────┘
                  ↓
         NotificationsScreen
         (shows all notifications)
```

Bon développement ! 🚀
