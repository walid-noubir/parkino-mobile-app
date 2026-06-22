🔧 CORRECTION FIRESTORE STRUCTURE - SLOT RESERVATIONS
================================================================================

 ANCIEN CHEMIN (CASSÉ):
parkings/main_parking/floors/etage_2/slot_reservations/{reservationId}

NOUVEAU CHEMIN (CORRIGÉ):
parkings/main_parking/floors/etage_2/slots/{slotId}/slot_reservations/{reservationId}

================================================================================
📊 CE QUI A CHANGÉ
================================================================================

Les réservations sont maintenant logiquement organisées SOUS CHAQUE SLOT, pas
directement sous le floor. Cela faitplus de sens architecturalement.

AVANT (Incorrect):
```
etage_2/ (document)
├─ slots/
│  ├─ slot_1/ (document)
│  ├─ slot_2/ (document)
│  └─ slot_3/ (document)
└─ slot_reservations/  ← Toutes les réservations ici
   ├─ {uuid1}
   ├─ {uuid2}
   └─ {uuid3}
```

APRÈS (Correct):
```
etage_2/ (document)
└─ slots/
   ├─ slot_1/ (document)
   │  └─ slot_reservations/
   │     ├─ {uuid1}
   │     └─ {uuid2}
   ├─ slot_2/ (document)
   │  └─ slot_reservations/
   │     └─ {uuid3}
   └─ slot_3/ (document)
      └─ slot_reservations/
```

================================================================================
🛠️ FICHIERS MODIFIÉS
================================================================================

lib/services/slot_reservation_service.dart:
  reserveSlot() - Chemin corrigé
  cancelReservation() - Chemin corrigé
  markReservationAsUsed() - Chemin corrigé
  getReservationForSlot() - Chemin corrigé
  cleanupExpiredReservations() - Chemin corrigé + itère tous les slots
  getActiveReservationsStream() - Chemin corrigé + itère tous les slots

================================================================================
🚀 PROCHAINES ÉTAPES
================================================================================

1️⃣ NETTOYER FIRESTORE (IMPORTANT!)
   Aller à: https://console.firebase.google.com
   Firestore Database
   Ouvrir: parkings → main_parking → floors → etage_2
   Supprimer la collection "slot_reservations" à la racine d'etage_2
   (Laissez les "slots" intacts avec slot_1 à slot_6)

2️⃣ METTRE À JOUR LES RÈGLES FIRESTORE
   Voir: APPLY_FIRESTORE_RULES.md pour les règles corrigées
   Les règles supportent maintenant: parkings/{id}/floors/{floor}/slots/{slot}/slot_reservations
   Appliquer les nouvelles règles

3️⃣ TESTER L'APPLICATION
   $ flutter clean
   $ flutter pub get
   $ flutter run

4️⃣ TESTER UNE RÉSERVATION
   → Cliquer sur une place verte
   → Vérifier que le code s'affiche
   → Vérifier dans Firestore:
     parkings/main_parking/floors/etage_2/slots/slot_1/slot_reservations/

================================================================================
AVANTAGES DE CETTE STRUCTURE
================================================================================

1. Logiquement plus correct:
   Chaque slot "possède" ses réservations

2. Permissions meilleures:
   On peut donner des permissions par slot

3. Requêtes plus efficaces:
   Les requêtes d'une seule place sont plus rapides

4. Scalabilité:
   Ajouter 100 places ne ralentit pas les requêtes

================================================================================
 DÉPANNAGE
================================================================================

Si erreur "Slot does not exist":
   → Vérifier que parkings/main_parking/floors/etage_2/slots/{slot_1-6} existent
   → Chaque slot doit avoir: slotNumber, floor, status, isReserved

Si erreur de permissions:
   → Mettre à jour les règles Firestore (voir APPLY_FIRESTORE_RULES.md)
   → Assurez-vous que path parkings/{id}/floors/{floor}/slots/{slot}/slot_reservations
     est autorisée en write pour les utilisateurs authentifiés

Si réservations ne s'affichent pas:
   → Vérifier dans Firestore console
   → Navigate à: parkings/main_parking/floors/etage_2/slots/slot_1
   → Chercher la sous-collection "slot_reservations"
   → Elle doit contenir les réservations créées

================================================================================
📞 RÉSUMÉ
================================================================================

Code corrigé: slot_reservation_service.dart
Chemin Firestore: parkings/.../slots/{slot}/slot_reservations (au lieu de slots_reservations au level etage_2)
Réservations: Maintenant créées logiquement sous chaque slot
Tests: Prêt à être testé

Prochaine action: Supprimer l'ancienne collection et tester!

================================================================================
