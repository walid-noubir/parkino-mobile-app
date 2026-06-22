# 📖 Exemple Complet - Flux de Réservation Avec Compteur

## Scénario: L'utilisateur réserve la place n°2 à 14:30

### 🟢 Étape 1: Réservation (14:30:00)

**L'utilisateur scanne le QR code et clique sur "Réserver"**

```dart
// Dans votre écran de réservation
onPressed: () {
  context.read<SlotReservationProvider>().reserveSlot(
    slotId: 'floor2_slot2',
    slotNumber: 2,
    userId: currentUser.id,
  );
}
```

### 🟢 Étape 2: Création de la réservation

**`SlotReservationProvider.reserveSlot()` s'exécute**

```dart
Future<SlotReservation> reserveSlot({...}) async {
  final reservation = await _service.reserveSlot(...);
  _currentReservation = reservation;
  
  // CLUE: Création de la notification avec timer
  if (_notificationProvider != null) {
    _notificationProvider!.addReservationNotification(
      title: 'Place réservée',
      spotNumber: 2,
      code: '1234',  // Code généré par Firestore
      reservationDuration: const Duration(minutes: 5),
    );
  }
  
  return reservation;
}
```

### 🟢 Étape 3: Notification et Timer créés

**`NotificationProvider.addReservationNotification()` s'exécute**

```dart
void addReservationNotification({
  required String title,
  required int spotNumber,
  required String code,
  required Duration reservationDuration,
}) {
  // 1. Créer la notification
  final notification = AppNotification(
    id: '1234567890',
    title: 'Place réservée',
    message: 'Vous avez réservé la place n°2. Code: 1234',
    type: 'reservation',
    spotNumber: 2,
    code: '1234',
    timestamp: DateTime.now(),  // 14:30:00
    isRead: false,
  );
  
  _notifications.insert(0, notification); // Au début de la liste
  
  // 2. Créer et démarrer le timer (5 minutes = 300 secondes)
  _activeTimer = _timerService.createTimer(
    reservationId: '1234',  // Code de réservation
    spotNumber: 2,
    duration: Duration(minutes: 5),
  );
  
  // 3. Configurer les callbacks
  _activeTimer!.onTick = (remainingTime) {
    print('⏱️ Temps restant: ${_activeTimer!.formattedTime}');
    notifyListeners(); // Rafraîchir l'UI (4:59, 4:58, etc)
  };
  
  _activeTimer!.onExpired = () {
    _handleTimerExpired(2, '1234');
  };
  
  notifyListeners(); // Première notif pour afficher le compteur
  print('🔔 Notification créée: Place #2');
}
```

### 🟢 Étape 4: L'UI se met à jour

**`ReservationCountdownTimer` s'affiche en haut du home screen**

```dart
// Consumer écoute le NotificationProvider
Consumer<NotificationProvider>(
  builder: (context, notificationProvider, _) {
    final activeTimer = notificationProvider.activeTimer;
    
    // activeTimer n'est PAS null, donc on affiche
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texte: "Réservation active" + "Place n°2"
          Column(
            children: [
              Text('Réservation active'),
              Text('Place n°2'),
            ],
          ),
          
          // Compteur: "05:00"
          Container(
            child: Text(
              activeTimer!.formattedTime, // "05:00"
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
)

// RÉSULTAT: En haut du home screen à 14:30:00
// ┌─────────────────────────────────┐
// │ Réservation active  │    05:00   │
// │ Place n°2          │ ( pulse )  │
// └─────────────────────────────────┘
```

### 🟢 Étape 5: Notification dans l'onglet

**`NotificationsScreen` affiche la nouvelle notification**

```dart
// Consumer écoute aussi le NotificationProvider
Consumer<NotificationProvider>(
  builder: (context, notificationProvider, _) {
    final notifications = notificationProvider.notifications;
    
    // notifications[0] est la nouvelle notification
    return ListView(
      children: notifications.map((notif) {
        return Container(
          // Affiche:
          // PARKINO
          // Place réservée (avec • bleu = non lue)
          // "Vous avez réservé la place n°2. Code: 1234"
          // ...
        );
      }).toList(),
    );
  }
)

// RÉSULTAT: Dans l'onglet Notifications à 14:30:00
// ┌──────────────────────────────────┐
// │ PARKINO        [●] (nouveau)      │
// │ Place réservée  Il y a 0s          │
// ├──────────────────────────────────┤
// │ 🟡 Place n°2 réservée             │
// │   Vous avez réservé la place n°2 │
// │   Code: 1234                     │
// └──────────────────────────────────┘
```

## ⏱️ Timeline: De 14:30 à 14:35

```
14:30:00 Réservation créée
         Compteur: 05:00
         Notification créée
         
14:30:01 ⏱️ Compteur: 04:59 (Timer.onTick() appelé)
         🔄 UI rafraîchie (notifyListeners)
         
14:30:02 ⏱️ Compteur: 04:58
         🔄 UI rafraîchie
         
...

14:34:58 ⏱️ Compteur: 00:02
         🔄 UI rafraîchie
         
14:34:59 ⏱️ Compteur: 00:01
         🔄 UI rafraîchie
         
14:35:00 ⚠️ EXPIRATION!
         Timer.onExpired() appelé
         _handleTimerExpired() crée notification d'expiration
         Compteur disparaît (SizedBox.shrink())
         _activeTimer = null
         Nouvelle notification: "Réservation expirée"
```

## 🔍 Vue détaillée des Callbacks

### Callback 1: onTick (toutes les secondes)

```dart
_activeTimer!.onTick = (remainingTime) {
  // remainingTime = Duration(minutes: 4, seconds: 59)
  // _activeTimer.formattedTime = "04:59"
  
  notifyListeners(); // ← CRITICAL: Rafraîchit Consumer
  
  // Consumer<NotificationProvider> rebuild
  // ReservationCountdownTimer rebuild
  // Affiche "04:59"
};
```

### Callback 2: onExpired (à 14:35:00)

```dart
_activeTimer!.onExpired = () {
  _handleTimerExpired(2, '1234'); // spotNumber, code
};

void _handleTimerExpired(int spotNumber, String code) {
  // Créer une notification d'expiration
  final expiredNotif = AppNotification(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: 'Réservation expirée',
    message: 'Votre réservation de la place n°2 a expiré.',
    type: 'expiration', // Type différent
    spotNumber: 2,
    code: '1234',
    timestamp: DateTime.now(), // 14:35:00
    isRead: false,
  );
  
  _notifications.insert(0, expiredNotif); // Au début
  _activeTimer = null; // Arrêter le timer
  notifyListeners(); // Rafraîchir
}
```

## 🎨 État de l'UI à chaque étape

### À 14:30:00 (juste après réservation)

```
HomeScreen:
└─ ReservationCountdownTimer (visible)
   ├─ "Réservation active"
   ├─ "Place n°2"
   └─ "05:00" ← animated pulse
   
NotificationsScreen:
└─ Notification (nouveau, non lue)
   ├─ PARKINO [●]
   ├─ Place réservée
   ├─ Il y a 0s
   └─ "Vous avez réservé la place n°2. Code: 1234"
```

### À 14:32:30 (au milieu)

```
HomeScreen:
└─ ReservationCountdownTimer (toujours visible)
   ├─ "Réservation active"
   ├─ "Place n°2"
   └─ "02:30" ← animated pulse (continue)
   
NotificationsScreen:
└─ Notification (notification toujours là)
   ├─ PARKINO (si lue, pas de ●)
   ├─ Place réservée
   ├─ Il y a 2 min 30s
   └─ "Vous avez réservé la place n°2. Code: 1234"
```

### À 14:35:00 (expiration)

```
HomeScreen:
└─ ∅ ReservationCountdownTimer (DISPARU!)
   (SizedBox.shrink() retourné)
   
NotificationsScreen:
├─ Notification NEW (expiration)
│  ├─ PARKINO [●] ← NOUVELLE
│  ├─ Réservation expirée
│  ├─ Il y a 0s
│  └─ "Votre réservation de la place n°2 a expiré."
│
└─ Notification (ancienne, toujours là)
   ├─ PARKINO
   ├─ Place réservée
   ├─ Il y a 5 min
   └─ "Vous avez réservé la place n°2. Code: 1234"
```

## 🐛 Debugging: Comment voir ce qui se passe

```dart
// Ajouter des print logs dans les callbacks

_activeTimer!.onTick = (remainingTime) {
  print('🕐 [${DateTime.now()}] Timer tick: ${_activeTimer!.formattedTime}');
  notifyListeners();
};

_activeTimer!.onExpired = () {
  print('⏰ [${DateTime.now()}] Timer EXPIRED for spot #2');
  _handleTimerExpired(2, '1234');
};

// Sortie console:
// 🕐 [14:30:01] Timer tick: 04:59
// 🕐 [14:30:02] Timer tick: 04:58
// ...
// 🕐 [14:34:59] Timer tick: 00:01
// ⏰ [14:35:00] Timer EXPIRED for spot #2
```

## 🎬 Résumé du flux complet

```
User: "Je veux réserver la place 2"
  ↓
SlotReservationProvider.reserveSlot()
  ↓
Firestore: Crée la réservation
  ↓
NotificationProvider.addReservationNotification()
  ├─ Crée appNotification
  ├─ Lance ReservationTimer (5min)
  └─ notifyListeners()
  ↓
Consumer widgets se rafraîchissent
  ├─ ReservationCountdownTimer: Affiche "05:00"
  └─ NotificationsScreen: Affiche "Place réservée"
  ↓
User voit:
  ├─ Compteur en haut du home screen
  └─ Notification dans l'onglet
  ↓
5 minutes passent... (Timer.onTick chaque seconde)
  ├─ 04:59, 04:58, ..., 00:01
  └─ Écran se met à jour en temps réel
  ↓
À 14:35:00: Timer expire
  ├─ onExpired() appelé
  ├─ Notification d'expiration créée
  ├─ Compteur disparaît
  └─ Notification "Réservation expirée" apparaît
  ↓
User peut voir:
  ├─ Historique de réservation
  └─ Notification d'expiration
```

Voilà! C'est le flux complet du système. 🚀
