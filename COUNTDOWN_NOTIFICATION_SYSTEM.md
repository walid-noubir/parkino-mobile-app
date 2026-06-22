# Système de Compteur Décroissant et Notifications de Réservation

## 🎯 Vue d'ensemble

Ce système implémente un compteur de réservation décroissant (5 minutes) affichage en haut de l'écran d'accueil et crée une notification dans l'onglet Notifications quand l'utilisateur réserve une place.

## 📁 Fichiers créés/modifiés

### 1. **Services**
- **`lib/services/reservation_timer_service.dart`** (NOUVEAU)
  - Service pour gérer les timers de réservation
  - Classe `ReservationTimer` : Gère un timer individuel (5 minutes)
  - Classe `ReservationTimerService` : Singleton pour gérer tous les timers

### 2. **Providers**
- **`lib/providers/reservation_notification_provider.dart`** (NOUVEAU)
  - Classe `AppNotification` : Modèle pour les notifications
  - Classe `NotificationProvider` : Gère toutes les notifications avec support du timer
  - Intégration automatique du timer lors d'une réservation
  - Détection et notification d'expiration

- **`lib/providers/slot_reservation_provider.dart`** (MODIFIÉ)
  - Ajout du `setNotificationProvider()` pour connecter les providers
  - Modification de `reserveSlot()` pour créer une notification
  - Modification de `cancelReservation()` pour annuler le timer

### 3. **Widgets**
- **`lib/widgets/reservation_countdown_widget.dart`** (NOUVEAU)
  - `ReservationCountdownTimer` : Widget affichable en haut de l'écran
  - Affiche: "Place n°X | MM:SS" avec animation pulse
  - Disparaît automatiquement quand le timer expire
  - `ReservationCountdownMini` : Version miniature pour les badges

### 4. **Écrans**
- **`lib/screens/home/home_screen.dart`** (MODIFIÉ)
  - Intégration du `ReservationCountdownTimer` en haut
  - Widget affiché au-dessus du contenu principal

- **`lib/screens/notifications/notifications_screen.dart`** (ENTIÈREMENT REFONDU)
  - Remplacé les notifications statiques par le `NotificationProvider`
  - Affiche les vraies notifications de réservation en temps réel
  - Support de plusieurs types: 'reservation', 'success', 'warning', 'expiration'
  - État vide avec message approprié

### 5. **Point d'entrée**
- **`lib/main.dart`** (MODIFIÉ)
  - Ajout du `NotificationProvider` aux providers
  - Connexion automatique entre `NotificationProvider` et `SlotReservationProvider`

## 🚀 Flux de fonctionnement

### Quand l'utilisateur réserve une place:

1. **`SlotReservationProvider.reserveSlot()` est appelé**
   ```
   reserveSlot() 
   → Crée la réservation dans Firestore
   → Appelle notificationProvider.addReservationNotification()
   ```

2. **`NotificationProvider.addReservationNotification()` s'exécute**
   ```
   addReservationNotification()
   → Crée une AppNotification avec le code et la place
   → Crée un ReservationTimer (5 minutes)
   → Ajoute des callbacks (onTick, onExpired)
   → notifyListeners() rafraîchit l'UI
   ```

3. **Le `ReservationCountdownTimer` affiche le compteur**
   ```
   Consumer<NotificationProvider> écoute les changements
   → Affiche "Place n°2 | 05:00" avec animation
   → Se met à jour chaque seconde
   ```

4. **L'utilisateur voit la notification**
   ```
   NotificationsScreen affiche en temps réel
   → Notification avec icône, titre, message
   → Point d'information non lue (si applicable)
   → Peut voir détails et copier le code
   ```

5. **Après 5 minutes (expiration)**
   ```
   ReservationTimer.onExpired() se déclenche
   → addReservationNotification() crée une notification d'expiration
   → Le compteur disparaît
   → Notification "Réservation expirée" apparaît
   ```

## 🎨 Architecture du Timer

```
ReservationTimerService (Singleton)
├── Map<String, ReservationTimer> _timers
│   └── ReservationTimer
│       ├── Timer _timer (ticks each second)
│       ├── Duration _remainingTime
│       ├── onTick() callback
│       └── onExpired() callback
└── Méthodes publiques:
    ├── createTimer()
    ├── getTimer()
    ├── cancelTimer()
    ├── cancelAllTimers()
    └── getActiveTimer()
```

## 📱 Types de notifications

| Type | Icône | Couleur | Déclencheur |
|------|-------|---------|-------------|
| `reservation` | event_available | Or | Réservation créée |
| `success` | check_circle | Vert | Place disponible |
| `warning` | warning_rounded | Orange | Place occupée |
| `expiration` | timer_off | Rouge | Réservation expirée |
| `info` | info | Bleu | D'autres infos |

## 🔄 Consumer Pattern

Le système utilise `Consumer<NotificationProvider>`:

```dart
Consumer<NotificationProvider>(
  builder: (context, notificationProvider, _) {
    final activeTimer = notificationProvider.activeTimer;
    // L'UI se met à jour automatiquement quand activeTimer change
  }
)
```

## ⚙️ Configuration

### Durée de la réservation
Dans `slot_reservation_provider.dart`:
```dart
_notificationProvider!.addReservationNotification(
  ...
  reservationDuration: const Duration(minutes: 5), // Modifier ici
);
```

### Style du compteur
Dans `reservation_countdown_widget.dart`:
```dart
// Modifier les couleurs, fonts, animations
ParkinoTheme.goldenYellow  // Couleur principale
ParkinoTheme.primaryDarkBlue  // Background
```

## 🧪 Tests

Pour tester manuellement:

1. Réserver une place (QR code)
2. Vérifier que le compteur apparaît en haut du home screen
3. Vérifier que la notification apparaît dans l'onglet Notifications
4. Attendre que le timer expire (ou modifier à 10 secondes pour tester)
5. Vérifier la notification d'expiration

## 🐛 Débogage

Ajoutez des logs pour tracer:
```
Slot reserved in provider: CODE
⏱️ Timer created for reservation: ID (MM:SS)
🔔 Reservation notification added: Place #2, Code: 1234
⏰ Reservation expired for spot #2
```

## 📝 Notes importantes

- **Singleton**: `ReservationTimerService` est un singleton (une seule instance)
- **Memory leaks**: Les timers sont annulés lors de `dispose()`
- **Real-time**: Utilise `Consumer` pour les mises à jour en temps réel
- **Responsive**: Le compteur s'adapte à toutes les tailles d'écran
- **i18n**: Les textes utilisen `AppLocalizations.t()`

## 🔌 Intégration avec Firestore

Le timer fonctionne **indépendamment** de Firestore:
- Firestore gère la persistance des réservations
- Le timer local affiche le temps restant
- À l'expiration, une notification est créée localement
- Synchronisation Firestore = responsabilité du SlotReservationService
