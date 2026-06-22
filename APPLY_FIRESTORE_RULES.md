🔐 CORRECTION DES RÈGLES FIRESTORE - RÉSERVATIONS DE PLACES
================================================================================

⚠️ PROBLÈME IDENTIFIÉ:

Les règles Firestore ne couvraient pas la sous-collection 'slot_reservations'.
Cela causait l'erreur "Dart exception thrown from converted Future".

SOLUTION APPLIQUÉE:

Nouvelles règles ajoutées pour:
  • parkings/main_parking/floors/{floor}/slots/{slot}
  • Sous-collection: slot_reservations

================================================================================
🚀 ÉTAPES POUR APPLIQUER LES RÈGLES
================================================================================

1. OUVRIR FIREBASE CONSOLE
   → https://console.firebase.google.com
   → Sélectionner votre projet "parkino-app"

2. ALLER À FIRESTORE DATABASE
   → Dans le menu gauche: Firestore Database
   → Cliquer sur l'onglet "Rules"

3. COPIER LES NOUVELLES RÈGLES
   → Ouvrir: FIRESTORE_RULES.txt
   → Copier les règles (à partir de ligne 7: "rules_version = '2';")

4. REMPLACER LES RÈGLES ACTUELLES
   → Sélectionner TOUT le contenu dans l'éditeur Firebase
   → Appuyer sur Ctrl+A
   → Coller les nouvelles règles
   → Cliquer sur "Publier"

5. ATTENDRE LA PUBLICATION
   ⏱️ Peut prendre 1-2 minutes
   Vous verrez: "Les règles ont été mises à jour avec succès"

6. TESTER L'APPLICATION
   → Retourner à Flutter
   → Cliquer sur une place verte
   → La réservation DEVRAIT fonctionner maintenant!

================================================================================
📋 VÉRIFIER LES RÈGLES APPLIQUÉES
================================================================================

Éléments clés dans les règles:

match /parkings/{parkingId}/floors/{floorId}/slots/{slotId}
   - allow read: if true;
   - allow write, delete: if true;

match /slot_reservations/{reservationId} [SOUS-COLLECTION]
   - allow read: if true;
   - allow create: if isAuthenticated();
   - allow update, delete: if true;

match /parkings/{parkingId}/{document=**}
   - allow read: if true;
   - allow write, delete: if true;

================================================================================
 SI TOUJOURS ERREUR APRÈS MISE À JOUR
================================================================================

1. Vider le cache Flutter:
   $ flutter clean
   $ flutter pub get

2. Redémarrer l'app:
   $ flutter run

3. Vérifier les logs:
   → Chercher "📍 Stack trace" pour voir l'erreur complète
   → Si l'erreur continue, copier le stack trace complet

4. Vérifier la structure Firestore:
   → Console Firebase
   → Firestore Database
   → Sélectionner collection "parkings"
   → Voir si "main_parking" → "floors" → "etage_2" → "slots" existent

5. Vérifier que Floor 2 a 6 slots:
   → slots: slot_1, slot_2, slot_3, slot_4, slot_5, slot_6
   → Chaque slot doit avoir champs: slotNumber, floor, status, occupied, isReserved

================================================================================
✨ APRÈS APPLICATION DES RÈGLES
================================================================================

Les utilisateurs authentifiés peuvent maintenant:

Lire les places de parking (etage_1, etage_2)
Lire les réservations existantes
CRÉER des réservations (le code 4 chiffres généré)
Mettre à jour/supprimer les réservations (en mode dev)

Les places vertes se reserveront instantanément avec un code 4 chiffres.

================================================================================
📞 BESOIN D'AIDE?
================================================================================

Si vous n'êtes pas sûr de comment appliquer les règles:

1. Dans Firebase Console, cliquer sur "?" (aide)
2. Chercher "Règles de sécurité Firestore"
3. Ou me dire; je vais vous guider pas à pas

================================================================================
