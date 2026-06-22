import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:parkino/models/index.dart';

class ConfirmationScreen extends StatelessWidget {
  final Reservation reservation;
  final String qrCodeData;

  const ConfirmationScreen({
    Key? key,
    required this.reservation,
    required this.qrCodeData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Empêche le retour
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Réservation confirmée'),
          elevation: 0,
          backgroundColor: Colors.green,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône de succès
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Message de succès
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Réservation confirmée!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Votre paiement de ${reservation.formattedPrice} a été accepté',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Détails de la réservation
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Détails de la réservation',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('ID de réservation:', reservation.id),
                        _buildDetailRow('Place:', reservation.slotId),
                        _buildDetailRow('Étage:', '${reservation.floor}e'),
                        _buildDetailRow('Durée:', '${reservation.durationHours} heure(s)'),
                        _buildDetailRow('Montant:', reservation.formattedPrice),
                        _buildDetailRow('Statut:', reservation.status.value),
                        _buildDetailRow('Date/Heure:', reservation.formattedDate),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // QR Code
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Votre QR Code d\'accès',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: QrImage(
                              data: qrCodeData,
                              version: QrVersions.auto,
                              size: 250,
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                  'Présentez ce QR code à l\'entrée pour accéder à votre place.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Informations importantes
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: 8),
                            Text(
                              'Important',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '• Le QR code ne fonctionne qu\'une seule fois',
                          style: TextStyle(fontSize: 12),
                        ),
                        const Text(
                          '• La réservation expire dans 15 minutes si non utilisée',
                          style: TextStyle(fontSize: 12),
                        ),
                        const Text(
                          '• Assurez-vous d\'être sur place avant l\'expiration',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Boutons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Retour à l'accueil
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retour à l\'accueil',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
