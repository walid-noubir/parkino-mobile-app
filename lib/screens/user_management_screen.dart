import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_auth_provider.dart';
import '../providers/reservation_provider.dart';
import '../localization/app_localizations.dart';
import '../navigation/main_navigation.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.t('user_management')),
        backgroundColor: const Color(0xFF0B2A4A),
      ),
      body: Consumer<FirebaseAuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          
          if (user == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No user logged in',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B2A4A),
                      ),
                      child: Text(AppLocalizations.t('back_to_sign_in')),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current User',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0B2A4A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildUserInfoRow('Email:', user.email ?? 'N/A'),
                        _buildUserInfoRow('Username:', user.displayName ?? 'Not set'),
                        _buildUserInfoRow('UID:', user.uid),
                        _buildUserInfoRow(
                          'Email Verified:',
                          user.emailVerified ? 'Yes' : 'No',
                        ),
                        _buildUserInfoRow(
                          'Created:',
                          user.metadata.creationTime?.toString() ?? 'N/A',
                        ),
                        _buildUserInfoRow(
                          'Last Sign In:',
                          user.metadata.lastSignInTime?.toString() ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigation(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.home),
                  label: Text(AppLocalizations.t('go_to_home')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B2A4A),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showSignOutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: Text(AppLocalizations.t('sign_out')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showDeleteFloor2DataDialog(context),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('🗑️ Supprimer Floor 2 (Admin)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0B2A4A),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(AppLocalizations.t('sign_out')),
          content: Text(AppLocalizations.t('are_you_sure_sign_out')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.t('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // FIX: Reset slot reservation state before signing out
              context.read<SlotReservationProvider>().resetOnLogout();
              context.read<FirebaseAuthProvider>().signOut();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppLocalizations.t('sign_out')),
          ),
        ],
      ),
    );
  }

  void _showDeleteFloor2DataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ SUPPRIMER COMPLÈTEMENT'),
        content: const Text(
          'ATTENTION ! Cette action va supprimer DÉFINITIVEMENT :\n\n'
          '• Les 3 places (B1, B2, B3)\n'
          '• Toutes les réservations du 2e étage\n'
          '• Tous les paiements associés\n\n'
          'Cette opération est IRRÉVERSIBLE !',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Afficher un indicateur de chargement
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              try {
                // Appeler la méthode de suppression
                await context.read<ReservationProvider>().deleteAllFloor2Data();
                
                // Fermer le chargement
                Navigator.pop(context);
                
                // Afficher le message de succès
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toutes les données du floor 2 ont été supprimées'),
                    duration: Duration(seconds: 3),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                // Fermer le chargement
                Navigator.pop(context);
                
                // Afficher le message d'erreur
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('SUPPRIMER'),
          ),
        ],
      ),
    );
  }
}
