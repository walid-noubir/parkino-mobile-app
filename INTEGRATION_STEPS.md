/// MODIFICATIONS POUR parking_map_screen.dart
/// Ajouter l'import pour Firebase Auth :

// import 'package:firebase_auth/firebase_auth.dart';
// import '../../models/index.dart';

/// DANS LA CLASSE _ParkingMapScreenState :

/// Ajouter cette méthode dans initState() :
@override
void initState() {
  super.initState();
  _setupAnimation();
  
  // ⚡ NOUVEAU : Nettoyer les réservations expirées au lancement
  _cleanupExpiredReservations();
}

/// Ajouter cette nouvelle méthode :
void _cleanupExpiredReservations() {
  // Récupérer le provider de réservation
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<SlotReservationProvider>().cleanupExpiredReservations();
  });
}

/// REMPLACER la méthode _buildParkingSpot par celle-ci pour afficher le statut:

Widget _buildParkingSpot({required ParkingSlot slot, int index = 0}) {
  // Déterminer la couleur selon l'état
  Color slotColor;
  Icon stateIcon;
  String stateLabel;

  if (slot.occupied) {
    slotColor = Colors.red.shade600;
    stateIcon = const Icon(Icons.close_rounded, color: Colors.white, size: 16);
    stateLabel = 'OCCUPÉE';
  } else if (slot.isReserved) {
    slotColor = Colors.orange.shade600;
    stateIcon = const Icon(Icons.timer, color: Colors.white, size: 16);
    stateLabel = 'RÉSERVÉE';
  } else {
    slotColor = Colors.green.shade600;
    stateIcon = const Icon(Icons.check_circle, color: Colors.white, size: 16);
    stateLabel = 'LIBRE';
  }

  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 400 + (index * 50)),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) {
      return Transform.translate(
        offset: Offset(0, (1 - value) * 20),
        child: Opacity(
          opacity: value,
          child: child,
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            slotColor.withValues(alpha: 0.8),
            slotColor.withValues(alpha: 1.0),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: slotColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showSpotDetails(slot: slot);
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Numéro du slot
              Text(
                '${slot.slotNumber}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              
              // Disponibilité
              const SizedBox(height: 4),
              Text(
                slot.availabilityDisplay,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),

              // État avec icône
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  stateIcon,
                  const SizedBox(width: 4),
                  Text(
                    stateLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white90,
                    ),
                  ),
                ],
              ),

              // Code de réservation (si réservée)
              if (slot.isReserved && slot.reservationCode != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    slot.reservationCode!,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

================================================================================
ÉTAPES D'INTÉGRATION COMPLÈTE
================================================================================

1. OUVRIR parking_map_screen.dart

2. AJOUTER LES IMPORTS :
   ```dart
   import 'package:firebase_auth/firebase_auth.dart';
   import '../../models/index.dart';
   ```

3. DANS LA CLASSE _ParkingMapScreenState :
   
   a. Remplacer initState() pour ajouter le nettoyage auto
   b. Remplacer _buildParkingSpot() pour afficher le nouveau statut
   c. Remplacer _showSpotDetails() par la version du fichier SLOT_RESERVATION_EXAMPLE.dart

4. COPIER LES MÉTHODES HELPER :
   - showReservationSuccessDialog()
   - _formatTime()
   - _buildDetailRow()

5. TESTER :
   - Lancer l'app
   - Aller à Floor 2
   - Cliquer sur une place libre (verte)
   - Confirmer la réservation
   - Voir le code s'afficher
   - La place devient orange/jaune avec le code
   - Attendre 5 minutes ou relancer l'app pour voir l'expiration

================================================================================
VÉRIFICATIONS AVANT PRODUCTION
================================================================================

Firestore Rules :
   Autoriser lecture/écriture des documents slot_reservations pour users authentifiés

Transactions :
   Vérifier que les transactions Firestore réussisent (tests unitaires)

Timer :
   Implémenter un countdown visuel pour les réservations actives

Notifications :
   Ajouter FCM pour notifier l'utilisateur avant expiration

Logs :
   Vérifier que les logs print() apparaissent correctement

État UI :
   Vérifier que le UI se met à jour quand une place est réservée

================================================================================
