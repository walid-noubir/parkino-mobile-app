import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import '/providers/slot_reservation_provider.dart';
import '/theme/parkino_theme.dart';

/// Widget pour afficher un avertissement quand l'utilisateur a une réservation active
class UniqueReservationGuard extends StatelessWidget {
  final String userId;
  final Widget? activeReservationChild;
  final VoidCallback? onReservationCancelled;

  const UniqueReservationGuard({
    super.key,
    required this.userId,
    this.activeReservationChild,
    this.onReservationCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SlotReservationProvider>(
      builder: (context, provider, _) {
        return FutureBuilder<bool>(
          future: provider.hasActiveReservation(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(ParkinoTheme.goldenYellow),
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorState(context);
            }

            final hasReservation = snapshot.data ?? false;

            if (!hasReservation) {
              return activeReservationChild ?? const SizedBox.shrink();
            }

            // L'utilisateur a une réservation active
            return FutureBuilder<dynamic>(
              future: provider.getUserActiveReservation(userId),
              builder: (context, reservationSnapshot) {
                if (reservationSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(ParkinoTheme.goldenYellow),
                    ),
                  );
                }

                final reservation = reservationSnapshot.data;
                return _buildActiveReservationWarning(context, reservation);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildActiveReservationWarning(BuildContext context, dynamic reservation) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ParkinoTheme.errorRed.withOpacity(0.1),
            ParkinoTheme.errorRed.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: ParkinoTheme.errorRed.withOpacity(0.5),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: ParkinoTheme.errorRed.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ParkinoTheme.errorRed.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: ParkinoTheme.errorRed,
                  size: 28,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Réservation active',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ParkinoTheme.errorRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Vous avez une réservation en cours',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ParkinoTheme.errorRed.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ParkinoTheme.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ParkinoTheme.errorRed.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Place n°${reservation?.slotNumber ?? '?'}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: ParkinoTheme.primaryDarkBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ParkinoTheme.goldenYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Code: ${reservation?.code ?? '?'}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: ParkinoTheme.goldenYellow,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  'Vous ne pouvez réserver qu\'une seule place à la fois.\nVeuillez attendre l\'expiration ou annuler cette réservation.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCancelConfirmation(context, reservation),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Annuler cette réservation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ParkinoTheme.errorRed,
                    foregroundColor: ParkinoTheme.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        border: Border.all(
          color: Colors.amber,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.amber),
              const Gap(12),
              Expanded(
                child: Text(
                  'Erreur lors de la vérification',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context, dynamic reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: Text(
          'Êtes-vous sûr de vouloir annuler la réservation de la place n°${reservation?.slotNumber}?\n\n'
          'Cette action est définitive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Garder'),
          ),
          ElevatedButton(
            onPressed: () => _cancelReservation(context, reservation),
            style: ElevatedButton.styleFrom(
              backgroundColor: ParkinoTheme.errorRed,
            ),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _cancelReservation(BuildContext context, dynamic reservation) async {
    Navigator.pop(context);

    try {
      await context.read<SlotReservationProvider>().cancelReservation(
        slotId: reservation.slotId,
        reservationId: reservation.id,
      );

      onReservationCancelled?.call();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée'),
            backgroundColor: ParkinoTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: ParkinoTheme.errorRed,
          ),
        );
      }
    }
  }
}
