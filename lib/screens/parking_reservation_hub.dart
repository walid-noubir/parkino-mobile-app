import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parkino/screens/index.dart';
import 'package:parkino/providers/index.dart';

class ParkingReservationHub extends StatelessWidget {
  const ParkingReservationHub({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkino - Réservation'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Réinitialiser les places'),
                    content: const Text(
                      'Êtes-vous sûr ? Toutes les réservations en attente seront supprimées et les places seront remises à disponible.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<ReservationProvider>().resetAllParkingSlots();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Places réinitialisées avec succès'),
                              duration: Duration(seconds: 2),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                        ),
                        child: const Text('Réinitialiser'),
                      ),
                    ],
                  ),
                );
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('⚠️ SUPPRIMER TOUT'),
                    content: const Text(
                      'ATTENTION ! Cela va supprimer COMPLÈTEMENT :\n\n'
                      '• Toutes les réservations du floor 2\n'
                      '• Tous les paiements associés\n'
                      '• Les 3 places (B1, B2, B3)\n\n'
                      'Cette action est irréversible !',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          context.read<ReservationProvider>().deleteAllFloor2Data();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('🗑️ Toutes les données du floor 2 ont été supprimées'),
                              duration: Duration(seconds: 3),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('SUPPRIMER'),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Réinitialiser places'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer tout floor 2'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ⚠️ CLOSED FLOOR 2 NOTICE
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.block, color: Colors.red, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '🚫 ÉTAGE 2 - FERMÉ DÉFINITIVEMENT',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Le 2e étage n\'est plus disponible.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Options principales
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Bouton de gestion des réservations
              _buildActionButton(
                context,
                icon: Icons.list,
                title: 'Mes réservations',
                subtitle: 'Voir mes réservations actives',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReservationManagementScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Bouton de validation QR code
              _buildActionButton(
                context,
                icon: Icons.qr_code_scanner,
                title: 'Valider QR Code',
                subtitle: 'Scanner ou coller un QR code',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const QRCodeValidationScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Informations
              const Text(
                'Informations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue),
                          SizedBox(width: 12),
                          Text(
                            'Statut',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '🚫 2e Étage: FERMÉ DÉFINITIVEMENT\n'
                        '   Aucune place disponible\n'
                        '   Les réservations ne sont pas possibles',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.8,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange),
                          SizedBox(width: 12),
                          Text(
                            'Cartes de test',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '✓ Acceptée: 4242424242424242\n'
                        '✗ Rejetée: 4000000000000000\n'
                        'Autres: Acceptées si valides\n\n'
                        'Date: MM/YY (ex: 12/25)\n'
                        'CVV: 3-4 chiffres (ex: 123)',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.8,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
