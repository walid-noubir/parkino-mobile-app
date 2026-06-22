🗑️ SUPPRIMER LA COLLECTION ORPHELINE - GUIDE COMPLET
================================================================================

 PROBLÈME: Firebase demande de confirmer avec un ID unique

SOLUTION: Suivez ces étapes exactes

================================================================================
📋 MÉTHODE 1: VIA FIREBASE CONSOLE (Recommandé)
================================================================================

1. OUVRIR FIREBASE CONSOLE
   → https://console.firebase.google.com
   → Sélectionner projet "parkino-app"

2. ALLER À FIRESTORE DATABASE
   → Cliquer sur "Firestore Database" dans le menu gauche

3. NAVIGUER À LA COLLECTION
   → Cliquer sur: parkings
   → Cliquer sur: main_parking
   → Cliquer sur: floors
   → Cliquer sur: etage_2

4. VOIR LA COLLECTION ORPHELINE
   Vous voyez "+ Add document" et "🗑️ Delete" à droite
   Vous voyez aussi "slot_reservations" (la collection à supprimer)

5. SUPPRIMER LA COLLECTION
   → HOVER sur "slot_reservations"
   → Cliquer sur les 3 POINTS VERTICAUX (⋯) à droite
   → Cliquer sur "Delete collection"

6. CONFIRMER LA SUPPRESSION
   → Vous verrez un modal qui dit:
     "Are you sure you want to delete this collection?"
   
   ⚠️ SI FIREBASE DEMANDE UN CODE UNIQUE:
   → Vous verrez un champ texte
   → Copier l'ID affiché (ex: "slot_reservations")
   → Coller dans le champ
   → Cliquer "Delete"

7. ATTENDRE LA SUPPRESSION
   ⏱️ Peut prendre 30 secondes
   La collection disparaîtra

================================================================================
📋 MÉTHODE 2: AUTO-DELETE VIA SCRIPT DART (Alternative)
================================================================================

Si la suppression manuelle ne fonctionne pas, utilisez cette fonction:

Créer un fichier: lib/utils/cleanup_firestore.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// Supprime la collection orpheline slot_reservations du floor etage_2
Future<void> deleteOrphanedReservationsCollection() async {
  try {
    print('🗑️ Suppression de la collection orpheline...');
    
    final firestore = FirebaseFirestore.instance;
    
    final etage2Ref = firestore
        .collection('parkings')
        .doc('main_parking')
        .collection('floors')
        .doc('etage_2');
    
    // Récupérer la collection orpheline
    final orphanedDocs = await etage2Ref
        .collection('slot_reservations')
        .get();
    
    print('📊 Trouvé ${orphanedDocs.docs.length} documents orphelins');
    
    // Supprimer chaque document
    for (final doc in orphanedDocs.docs) {
      await doc.reference.delete();
      print('   ✓ Supprimé: ${doc.id}');
    }
    
    print('Collection orpheline supprimée!');
  } catch (e) {
    print(' Erreur: $e');
  }
}
```

Appeler cette fonction UNE FOIS au démarrage de l'app:
```dart
// Dans main.dart, après authentication:
await deleteOrphanedReservationsCollection();
```

================================================================================
❓ SI FIREBASE AFFICHE "Collection requires an ID"
================================================================================

Ça ne devrait pas arriver quand on supprime. Mais si ça arrive:

1. Firebase peut demander de confirmer en tapant l'ID
2. Chercher le champ de texte
3. Taper: slot_reservations
4. Cliquer Delete

Ou essayer autre approche:
1. Cliquer sur ⋯ (3 points)
2. Cliquer dans le champ vide qui apparaît
3. Taper l'ID affiché
4. Cliquer "Delete"

================================================================================
APRÈS SUPPRESSION
================================================================================

Vérifier que la collection est bien partie:

1. Rafraîchir la page Firebase Console (F5)
2. Naviguer à: parkings → main_parking → floors → etage_2
3. Vérifier qu'il y a SEULEMENT:
    "slots" (collection)
    PAS de "slot_reservations"
4. Ouvrir "slots" et vérifier:
    slot_1, slot_2, slot_3, slot_4, slot_5, slot_6 existent
    Chacun a sa sous-collection "slot_reservations" (vide au départ, c'est normal!)

================================================================================
🎯 PUIS: TESTER L'APP
================================================================================

1. flutter clean
2. flutter pub get
3. flutter run
4. Se connecter
5. Aller à Map
6. Cliquer sur une place verte
7. Vérifier que le code s'affiche
8. Vérifier dans Firestore:
   parkings/main_parking/floors/etage_2/slots/slot_1/slot_reservations/
   → Un nouveau document devrait être créé avec le code!

================================================================================
💡 ASTUCE: SI VOUS NE VOYEZ PAS LES 3 POINTS
================================================================================

Parfois Firebase ne montre pas les 3 points menu. Essayez:

1. Cliquer directement sur "slot_reservations" pour l'ouvrir
2. Regarder en haut à gauche pour un menu "Delete collection"
3. Ou: ouvrir les outils de développement (F12) et chercher
   dans les options du navigateur

================================================================================
🆘 DERNIER RECOURS: SUPPRIMER VIA GCLOUD CLI
================================================================================

Si rien ne marche via console, utilisez Firebase CLI:

$ npm install -g firebase-tools
$ firebase login
$ firebase firestore:delete parkings/main_parking/floors/etage_2/slot_reservations --recursive

(Confirmer avec "y" quand demandé)

================================================================================
