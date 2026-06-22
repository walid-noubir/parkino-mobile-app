📋 GUIDE COMPLET D'IMPLÉMENTATION - SYSTÈME DE RÉSERVATION DE PARKING (5 MINUTES)

================================================================================
FICHIERS CRÉÉS
================================================================================

1. 📄 lib/models/slot_reservation.dart
   - Nouveau modèle SlotReservation pour les réservations courtes (5 minutes)
   - Énumération SlotReservationStatus (active, expired, used)
   - Propriétés: id, slotId, code (4 chiffres), userId, createdAt, expiresAt
   - Méthodes: isExpired, isActive, timeRemaining, toJson(), copyWith()

2. 📄 lib/services/slot_reservation_service.dart
   - Service complet de gestion des réservations avec transactions Firestore
   - Fonction generateReservationCode() : génère un code de 4 chiffres
   - Fonction reserveSlot() : réserve une place avec transaction Firestore
   - Fonction cancelReservation() : annule une réservation
   - Fonction markReservationAsUsed() : marque comme utilisée
   - Fonction cleanupExpiredReservations() : nettoie les réservations expirées
   - Fonction getExpiredReservations() : récupère les réservations expirées
   - Streams : getActiveReservationsStream() pour écouter les réservations actives

3. 📄 lib/providers/slot_reservation_provider.dart
   - Provider ChangeNotifier pour gérer l'état des réservations
   - Propriétés: currentReservation, activeReservations, isLoading, error
   - Méthodes: reserveSlot(), cancelReservation(), markAsUsed()
   - Stream : getActiveReservationsStream()

================================================================================
FICHIERS MODIFIÉS
================================================================================

1. 📝 lib/models/index.dart
   + export 'slot_reservation.dart';

2. 📝 lib/services/parking_models.dart
   Classe ParkingSlot :
   + Ajout champs: isReserved, reservationCode, reservationId
   + Propriété: statusDisplay (retourne "Libre", "Réservée", "Occupée")
   + Propriété: canBeReserved (true si libre ET non réservée)
   + Mise à jour du constructeur fromFirestore() pour lire ces nouveaux champs

3. 📝 lib/services/index.dart
   + export 'slot_reservation_service.dart';

4. 📝 lib/providers/index.dart
   + export 'slot_reservation_provider.dart';

5. 📝 lib/main.dart
   + import 'providers/slot_reservation_provider.dart';
   + Ajout: ChangeNotifierProvider(create: (context) => SlotReservationProvider())

================================================================================
STRUCTURE FIRESTORE - FLOOR 2
================================================================================

parkings/
  main_parking/
    floors/
      etage_2/
        doc: { totalSpots: 6, availableSpots: ..., occupiedSpots: ..., ... }
        
        slots/
          slot_1/
            doc: {
              slotNumber: 1,
              floor: 2,
              status: "free" | "occupied",
              isReserved: false,
              reservationId: "uuid...",        ← NEW
              reservationCode: "1234",          ← NEW
              updatedAt: timestamp
            }
        
        slot_reservations/          ← NEW SUBCOLLECTION
          reservation_uuid1/
            doc: {
              id: "uuid...",
              slotId: "slot_1",
              slotNumber: 1,
              floor: 2,
              code: "1234",
              userId: "user_id...",
              status: "active" | "expired" | "used",
              createdAt: ISO8601,
              expiresAt: ISO8601,
              used: false
            }

================================================================================
RÈGLES DE RÉSERVATION
================================================================================

1.  PEUT ÊTRE RÉSERVÉE :
   - status == "free"
   - isReserved == false

2.  LORS DE LA RÉSERVATION :
   - Générer code aléatoire 4 chiffres (1000-9999)
   - isReserved ← true
   - reservationId ← UUID de la réservation
   - reservationCode ← "1234"
   - Créer document dans slot_reservations

3.  NE PEUT PAS RÉSERVER :
   - Place occupée (status == "occupied")
   - Place déjà réservée (isReserved == true)

4. ⏰ EXPIRATION (5 minutes) :
   - Comparaison: DateTime.now() > expiresAt
   - Action: Remettre isReserved à false
   - Mettre status de la réservation à "expired"
   - Nettoyer le document de réservation

================================================================================
UTILISATION - CODE FLUTTER
================================================================================

1️⃣ RÉSERVER UNE PLACE :
```dart
final slotReservationProvider = context.read<SlotReservationProvider>();
final currentUser = FirebaseAuth.instance.currentUser;

try {
  final reservation = await slotReservationProvider.reserveSlot(
    slotId: 'slot_1',
    slotNumber: 1,
    userId: currentUser?.uid ?? 'anonymous',
  );
  
  // Afficher le code : reservation.code (ex: "5432")
  print('🎟️ Votre code de réservation: ${reservation.code}');
  print('⏱️ Expires in: ${reservation.timeRemaining}');
} catch (e) {
  print(' Erreur: $e');
}
```

2️⃣ ANNULER UNE RÉSERVATION :
```dart
await slotReservationProvider.cancelReservation(
  slotId: 'slot_1',
  reservationId: 'reservation_uuid',
);
```

3️⃣ MARQUER COMME UTILISÉE :
```dart
await slotReservationProvider.markAsUsed(
  slotId: 'slot_1',
  reservationId: 'reservation_uuid',
);
```

4️⃣ NETTOYER LES RÉSERVATIONS EXPIRÉES :
```dart
// Au lancement de l'écran :
@override
void initState() {
  super.initState();
  context.read<SlotReservationProvider>().cleanupExpiredReservations();
}
```

5️⃣ ÉCOUTER LES RÉSERVATIONS ACTIVES :
```dart
Stream<List<SlotReservation>> reservations = 
  context.read<SlotReservationProvider>().getActiveReservationsStream();

reservations.listen((list) {
  print('Réservations actives: ${list.length}');
  for (var r in list) {
    print('  - Slot ${r.slotId}: ${r.code} (${r.timeRemaining})');
  }
});
```

================================================================================
SÉCURITÉ - TRANSACTIONS FIRESTORE
================================================================================

🔒 TRANSACTION POUR RÉSERVER :
1. Vérifier préconditions (place libre + non réservée)
2. Générer code aléatoire
3. Créer réservation
4. Mettre à jour slot
5. TOUT ATOMIQUE : Soit tout réussit, soit tout échoue

Cela évite les conditions de course (race conditions) :
- Deux utilisateurs ne peuvent pas réserver la même place
- Firestore gère automatiquement les conflits

🔒 TRANSACTION POUR ANNULER :
1. Mettre à jour le slot (isReserved → false)
2. Mettre à jour la réservation (status → expired)
3. ATOMIQUE

================================================================================
AFFICHAGE DANS L'UI
================================================================================

📍 ÉTATS DE LA PLACE :
   🟢 LIBRE       : Vert, bouton "Réserver"
   🟡 RÉSERVÉE    : Jaune/Orange, affiche "Code: 1234", bouton "Annuler"
   🔴 OCCUPÉE     : Rouge, aucun bouton d'action

📍 TINIER DANS LA RÉSERVATION :
   Affiche le temps restant: "4:32", "2:15", "0:45"
   Si temps ≤ 1 minute: Afficher en rouge et alerter

📍 APRÈS RÉSERVATION (Dialog) :
    Congratulations!
   🎟️ Your Code: 1234
   ⏱️ Valid for: 5 minutes
   [Cancel Reservation] [OK]

================================================================================
FONCTIONNALITÉS CRITIQUES
================================================================================

 ID SLOT INFO :
   - slotId : "slot_1" (clé du document)
   - slotNumber : 1 (le numéro affiché)

 GÉNÉRATION CODE :
   - Aléatoire entre 1000 et 9999
   - Formaté comme string: "1234"

 VÉRIFICATION EXPIRATION :
   - Automatique au chargement (initState)
   - Timer optionnel pour vérification en temps réel
   - Nettoyage des données Firestore

 ÉVITER RACE CONDITIONS :
   - Firestore Transaction utilisée
   - Lecture + Vérification + Écriture atomique

================================================================================
NEXT STEPS - POUR ALLER PLUS LOIN
================================================================================

1. ⏱️ Timer en temps réel :
   - Ajouter Timer(Duration(seconds: 1), ...) pour mettre à jour countdown
   - Alerter quand < 1 minute

2. 📱 Notifications :
   - Firebase Cloud Messaging pour notifier l'utilisateur
   - Rappel avant expiration

3. 💰 Intégration paiement :
   - Après réservation, rediriger vers paiement
   - Confirmer la réservation complet après paiement

4. 📊 Statistiques :
   - Tracker les réservations par utilisateur
   - Analyser les taux de conversion

5. 🔔 Webhook :
   - Ajouter une fonction Firebase pour nettoyer les réservations expiréS regulièrement

================================================================================
