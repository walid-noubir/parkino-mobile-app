import 'package:cloud_firestore/cloud_firestore.dart';

/// Supprime la collection orpheline slot_reservations du floor etage_2
/// Appeler UNE FOIS au démarrage de l'app
Future<void> deleteOrphanedReservationsCollection() async {
  try {
    print('🔍 Vérification des collections orphelines...');
    
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
    
    if (orphanedDocs.docs.isEmpty) {
      print('Aucune collection orpheline trouvée');
      return;
    }
    
    print('🗑️ Trouvé ${orphanedDocs.docs.length} documents orphelins à supprimer...');
    
    // Supprimer chaque document
    int deletedCount = 0;
    for (final doc in orphanedDocs.docs) {
      await doc.reference.delete();
      deletedCount++;
      print('   ✓ Supprimé: ${doc.id}');
    }
    
    print('Collection orpheline supprimée! ($deletedCount documents supprimés)');
  } catch (e) {
    print('Erreur lors du nettoyage: $e');
    // Continue anyway, ne pas bloquer l'app
  }
}
