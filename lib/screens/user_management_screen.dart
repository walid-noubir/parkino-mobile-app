import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_auth_provider.dart';
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
        title: const Text('User Management'),
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
                      child: const Text('Back to Sign In'),
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
                          user.emailVerified ? '✅ Yes' : '❌ No',
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
                  label: const Text('Go to Home'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B2A4A),
                    minimumSize: const Size.fromHeight(50),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _showSignOutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
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
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FirebaseAuthProvider>().signOut();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
