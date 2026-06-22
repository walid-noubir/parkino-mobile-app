import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:parkino/models/index.dart';
import 'package:parkino/providers/index.dart';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({Key? key}) : super(key: key);

  @override
  State<ReservationManagementScreen> createState() => _ReservationManagementScreenState();
}

class _ReservationManagementScreenState extends State<ReservationManagementScreen> {
  @override
  Widget build(BuildContext context) {
    // Get the real Firebase user ID
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mes réservations'),
          elevation: 0,
          backgroundColor: Colors.blueAccent,
        ),
        body: const Center(
          child: Text('Veuillez vous connecter'),
        ),
      );
    }
    
    final reservationProvider = context.read<ReservationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes réservations'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: StreamBuilder<List<Reservation>>(
        stream: reservationProvider.getUserReservationsStream(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur: ${snapshot.error}'),
            );
          }

          final reservations = snapshot.data ?? [];

          if (reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.parking,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune réservation',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                    ),
                    child: const Text(
                      'Faire une réservation',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              return _buildReservationCard(context, reservation);
            },
          );
        },
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, Reservation reservation) {
    final statusColor = _getStatusColor(reservation.status);
    final statusIcon = _getStatusIcon(reservation.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text('Place ${reservation.slotId}'),
        subtitle: Text(
          '${reservation.formattedPrice} • ${reservation.status.value}',
          style: TextStyle(color: statusColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('ID:', reservation.id),
                _buildDetailRow('Place:', reservation.slotId),
                _buildDetailRow('Étage:', '${reservation.floor}e'),
                _buildDetailRow('Durée:', '${reservation.durationHours} heure(s)'),
                _buildDetailRow('Montant:', reservation.formattedPrice),
                _buildDetailRow('Statut:', reservation.status.value),
                _buildDetailRow('Date/Heure:', reservation.formattedDate),
                _buildDetailRow(
                  'Expire dans:',
                  _formatTimeUntilExpiration(reservation.expiresAt),
                ),
                const SizedBox(height: 16),

                // Affiche le QR code si la réservation est confirmée
                if (reservation.status == ReservationStatus.confirmed &&
                    reservation.qrCode != null)
                  _buildQRCodeSection(context, reservation)
                else if (reservation.status == ReservationStatus.pendingPayment)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.pending, color: Colors.orange),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'En attente de paiement',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (reservation.status == ReservationStatus.used)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Réservation utilisée',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (reservation.status == ReservationStatus.expired)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.red),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Réservation expirée',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeSection(BuildContext context, Reservation reservation) {
    try {
      final qrCodeData = reservation.qrCode ?? '';

      if (qrCodeData.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'QR Code d\'accès:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: QrImage(
                data: qrCodeData,
                version: QrVersions.auto,
                size: 200,
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'QR code pour l\'accès. Présentez-le à l\'entrée.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'QR code expiré.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    } catch (e) {
      return const Text(
        'Erreur lors du chargement du QR code',
        style: TextStyle(color: Colors.red),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pendingPayment:
        return Colors.orange;
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.used:
        return Colors.blue;
      case ReservationStatus.expired:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pendingPayment:
        return Icons.pending;
      case ReservationStatus.confirmed:
        return Icons.check_circle;
      case ReservationStatus.used:
        return Icons.done_all;
      case ReservationStatus.expired:
        return Icons.cancel;
    }
  }

  String _formatTimeUntilExpiration(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return 'Expirée';
    }

    final minutes = difference.inMinutes;
    final hours = difference.inHours;

    if (hours > 0) {
      return '$hours h ${minutes % 60} min';
    } else {
      return '$minutes min';
    }
  }
}
