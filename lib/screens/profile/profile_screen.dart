import 'package:flutter/material.dart';
import '../../screens/auth/sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildProfileHeader(),
              const SizedBox(height: 28),
              _buildProfileInfo(),
              const SizedBox(height: 32),
              _buildActionButtons(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/parkino_logo.png',
            width: 100,
            height: 100,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: _primaryDarkBlue,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Account',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.88),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_goldenYellow, Color(0xFFFFB800)],
                    ),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: _goldenYellow.withValues(alpha: 0.4),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: _primaryDarkBlue,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_goldenYellow, Color(0xFFFFB800)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: _goldenYellow.withValues(alpha: 0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.edit,
                    size: 18,
                    color: _primaryDarkBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'John Doe',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _primaryDarkBlue,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'john.doe@parkino.com',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF999999),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProfileInfoRow(
            icon: Icons.person_outline,
            label: 'Username',
            value: 'johndoe',
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildProfileInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'john.doe@parkino.com',
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildProfileInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+1 (555) 123-4567',
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildProfileInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Member Since',
            value: 'January 15, 2024',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _goldenYellow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: _primaryDarkBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF999999),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _primaryDarkBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_goldenYellow, Color(0xFFFFB800)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _goldenYellow.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit Profile - Coming soon'),
                    backgroundColor: _primaryDarkBlue,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.edit_rounded,
                      color: _primaryDarkBlue,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'EDIT PROFILE',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _primaryDarkBlue,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade500, Colors.red.shade700],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                _showLogoutConfirmation(context);
              },
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.logout_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'LOGOUT',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirm Logout',
          style: TextStyle(
            color: _primaryDarkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: Color(0xFF666666),
            fontSize: 14,
          ),
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _goldenYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No',
              style: TextStyle(
                color: _primaryDarkBlue,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignInScreen(),
                ),
              );
            },
            child: const Text(
              'Yes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
