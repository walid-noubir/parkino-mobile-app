 VÉRIFIER LA STRUCTURE FIRESTORE
================================================================================

AVANT DE RÉSERVER, ASSUREZ-VOUS QUE LA STRUCTURE EXISTE!

================================================================================
📍 STRUCTURE ATTENDUE
================================================================================

Collection: parkings/
  ↓ Document: main_parking/
    ↓ Collection: floors/
      ↓ Document: etage_2/
        ↓ Collection: slots/
          ├─ Document: slot_1
          │  ├─ slotNumber: 1
          │  ├─ floor: 2
          │  ├─ occupied: false (ou true)
          │  ├─ status: "free" ou "occupied"
          │  ├─ distanceCm: 123.5
          │  ├─ updatedAt: Timestamp
          │  ├─ isReserved: false      ← NOUVEAU
          │  ├─ reservationCode: null  ← NOUVEAU
          │  └─ reservationId: null    ← NOUVEAU
          ├─ Document: slot_2
          │  ├─ ... (mêmes champs)
          ├─ Document: slot_3
          │  ├─ ... (mêmes champs)
          ├─ Document: slot_4
          ├─ Document: slot_5
          └─ Document: slot_6
        
        ↓ Collection: slot_reservations/
          (Vide au départ, se remplit après chaque réservation)
          
          ↓ Document: {uuid}
            ├─ id: "uuid-xxx"
            ├─ slotId: "slot_3"
            ├─ slotNumber: 3
            ├─ floor: 2
            ├─ code: "8547"
            ├─ userId: "user_temp_1777047516199"
            ├─ status: "active"
            ├─ used: false
            ├─ createdAt: "2026-04-24T10:30:00Z"
            └─ expiresAt: "2026-04-24T10:35:00Z"

================================================================================
🔍 VÉRIFIER DANS FIREBASE CONSOLE
================================================================================

1. OUVRIR: https://console.firebase.google.com

2. SÉLECTIONNER PROJET: parkino-app

3. ALLER À: Firestore Database

4. CHERCHER LA COLLECTION:
   parkings → main_parking → floors → etage_2 → slots
   
   VOUS DEVRIEZ VOIR:
    slot_1 (vert si occupied=false)
    slot_2 (vert si occupied=false)
    slot_3 (vert si occupied=false)
    slot_4 (vert si occupied=false)
    slot_5 (vert si occupied=false)
    slot_6 (vert si occupied=false)

5. CLIQUER SUR un slot (ex: slot_1)
   
   VÉRIFIER LES CHAMPS:
    slotNumber: 1
    floor: 2
    occupied: (boolean)
    status: "free" ou "occupied"
    distanceCm: (nombre)
    updatedAt: (date)
    isReserved: false ou null ← IMPORTANT
    reservationCode: null ← IMPORTANT
    reservationId: null ← IMPORTANT

================================================================================
⚠️ SI LES SLOTS N'EXISTENT PAS
================================================================================

Si vous ne voyez pas les slots dans Firestore:

1. LE CODE DEVRAIT LES CRÉER AUTOMATIQUEMENT
   - À l'ouverture de l'app
   - Lors du premier accès à la carte

2. ATTENDEZ QUE L'APP SE CHARGE:
    Vous devriez voir: " User data loaded from Firestore"
   
3. PUIS VÉRIFIÉ DANS FIREBASE CONSOLE

4. SI TOUJOURS PAS DE SLOTS:
   - Vérifier les logs Flutter pour les erreurs
   - La structure n'a pas pu être créée
   - Peut être une erreur de permissions

================================================================================
⚠️ SI LES SLOTS N'ONT PAS TOUS LES CHAMPS
================================================================================

Actuellement manquants (AVANT première réservation):
   - isReserved: (peut ne pas exister encore)
   - reservationCode: (peut ne pas exister encore)
   - reservationId: (peut ne pas exister encore)

C'EST NORMAL! Ces champs sont créés lors de la PREMIÈRE RÉSERVATION.

Après une réservation sur slot_3:
    slot_3.isReserved = true
    slot_3.reservationCode = "8547"
    slot_3.reservationId = "uuid-xxx"

================================================================================
 CHECKLIST COMPLÈTE
================================================================================

Avant de tester la réservation:

□ Firestore Database existe dans Firebase Console
□ Collection "parkings" existe
□ Document "main_parking" existe
□ Collection "floors" existe sous main_parking
□ Document "etage_2" existe sous floors
□ Collection "slots" existe sous etage_2
□ 6 documents existent: slot_1, slot_2, slot_3, slot_4, slot_5, slot_6
□ Chaque slot a les champs: slotNumber, floor, occupied, status, distanceCm
□ Champ "occupied" est false pour au moins 1 slot
□ Règles Firestore sont appliquées (voir APPLY_FIRESTORE_RULES.md)
□ User est authentifié (voir logs: " User signed in successfully")

================================================================================
🧪 TEST MANUEL
================================================================================

1. Ouvrir l'app Flutter
2. Se connecter (email: gbw3660@gmail.com, password: ...)
3. Attendre le chargement " User data loaded from Firestore"
4. Aller à la carte (Map)
5. Vérifier que vous voyez des places VERTES (occupied=false)
6. Cliquer sur une place verte
7. SI LA RÉSERVATION FONCTIONNE:
    Un dialog montrera le code 4 chiffres
    Dans Firestore, le slot_reservations aura un nouveau document
8. SI ERREUR:
    Lire les logs Flutter
    Chercher l'étape qui échoue
    Vérifier APPLY_FIRESTORE_RULES.md

================================================================================
📋 STRUCTURE FIRESTORE - COMMANDE FIREBASE CLI
================================================================================

Si vous avez Firebase CLI installé:

firebase firestore:get --recursive parkings/main_parking/floors/etage_2

Ou dans Firebase Emulator:

npm install -g firebase-tools
firebase emulators:start

================================================================================
