/// Exemple d'intégration du système de réservation
/// À intégrer dans parking_map_screen.dart

/// REMPLACER la méthode _showSpotDetails par celle-ci :
void _showSpotDetails({required ParkingSlot slot}) {
  // Récupérer le provider de réservation
  final slotReservationProvider = context.read<SlotReservationProvider>();
  final currentUser = FirebaseAuth.instance.currentUser;

  // Récupérer le texte localisé
  final locale = AppLocalizations.of(context);

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('${locale?.translate("spot") ?? "Spot"} #${slot.slotNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟢🟡🔴 Statut de la place
              _buildDetailRow(
                'Statut:',
                slot.occupied
                    ? '🔴 OCCUPÉE'
                    : slot.isReserved
                        ? '🟡 RÉSERVÉE'
                        : '🟢 LIBRE',
              ),
              const SizedBox(height: 12),

              // Disponibilité
              _buildDetailRow(
                'Disponibilité:',
                '${slot.availabilityDisplay} - ${slot.canBeReserved ? 'Peut être réservée' : 'Non disponible'}',
              ),
              const SizedBox(height: 12),

              // Distance
              _buildDetailRow(
                'Distance:',
                '${slot.distanceCm.toStringAsFixed(1)} cm',
              ),
              const SizedBox(height: 12),

              // Dernier mise à jour
              _buildDetailRow(
                'Mise à jour:',
                _formatTime(slot.updatedAt),
              ),
              const SizedBox(height: 16),

              // 🔴 Si OCCUPÉE
              if (slot.occupied) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.block, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cette place est actuellement occupée. Veuillez choisir une autre place.',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
              // 🟡 Si RÉSERVÉE
              else if (slot.isReserved) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Place réservée temporairement',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (slot.reservationCode != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Code: ${slot.reservationCode}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ]
              // 🟢 Si LIBRE
              else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Place libre - Vous pouvez la réserver maintenant!',
                          style: TextStyle(fontSize: 12, color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          // Bouton Annuler (fermer le dialog)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),

          // Bouton Réserver (si place est libre)
          if (slot.canBeReserved)
            ElevatedButton(
              onPressed: () async {
                // Fermer le dialogue
                Navigator.pop(context);

                // Afficher un loader
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  // Réserver la place
                  final reservation = await slotReservationProvider.reserveSlot(
                    slotId: 'slot_${slot.slotNumber}',
                    slotNumber: slot.slotNumber,
                    userId: currentUser?.uid ?? 'anonymous',
                  );

                  // Fermer le loader
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  // Afficher le code de réservation dans un dialogue succès
                  if (!context.mounted) return;
                  showReservationSuccessDialog(context, reservation);
                } catch (e) {
                  // Fermer le loader
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  // Afficher l'erreur
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                'Réserver',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Affiche un dialogue de succès après réservation
void showReservationSuccessDialog(
  BuildContext context,
  SlotReservation reservation,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Réservation confirmée!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône succès
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Votre code de réservation:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),

          // Code de réservation en GROS
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Text(
              reservation.code,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                letterSpacing: 4,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Infos supplémentaires
          Text(
            'Place: ${reservation.slotId}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),

          Text(
            'Valide pour: ${reservation.timeRemaining}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
          ),
          const SizedBox(height: 4),

          Text(
            'Créée à: ${_formatTime(reservation.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),

          // Avis important
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.orange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Votre réservation expire dans 5 minutes. Présentez ce code à l\'accès.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

/// Helper pour formater les dates/heures
String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final day = dateTime.day;
  final month = dateTime.month;
  final year = dateTime.year;
  return '$day/$month/$year à $hour:$minute';
}

/// Helper pour afficher les détails
Widget _buildDetailRow(String label, String value) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 1,
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      Expanded(
        flex: 2,
        child: Text(
          value,
          style: const TextStyle(fontSize: 13),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}

// ⚠️ À AJOUTER À L'IMPORT DU FICHIER:
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:parkino/models/index.dart';
// import 'package:parkino/providers/index.dart';
