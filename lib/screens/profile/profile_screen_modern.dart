import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:gap/gap.dart';
import '../../localization/app_localizations.dart';
import '../../screens/auth/sign_in_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../providers/slot_reservation_provider.dart';
import '../../providers/language_provider.dart';
import '../../widgets/modern_widgets.dart';
import '../../theme/parkino_theme.dart';

class ProfileScreenModern extends StatefulWidget {
  const ProfileScreenModern({super.key});

  @override
  State<ProfileScreenModern> createState() => _ProfileScreenModernState();
}

class _ProfileScreenModernState extends State<ProfileScreenModern> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  String? _profileImageBase64;
  String? _displayName;
  String? _email;
  String? _phone;
  String? _memberSince;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data();
          final createdAtTimestamp = data?['createdAt'] as Timestamp?;
          
          String? formattedDate;
          if (createdAtTimestamp != null) {
            final dateTime = createdAtTimestamp.toDate();
            formattedDate = _formatDate(dateTime);
          }
          
          setState(() {
            _displayName = data?['displayName'] ?? user.displayName ?? 'User';
            _email = data?['email'] ?? user.email ?? '';
            _profileImageBase64 = data?['photoUrl']; // Image stockée en base64
            _phone = data?['phone'] ?? 'Not provided';
            _memberSince = formattedDate ?? 'Unknown';
          });
          print('User data loaded from Firestore');
        } else {
          setState(() {
            _displayName = user.displayName ?? 'User';
            _email = user.email ?? '';
            _phone = 'Not provided';
            _memberSince = 'Unknown';
          });
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  /// Format timestamp to readable date
  String _formatDate(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
  }

  Future<void> _pickAndUploadProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress the image
      );

      if (pickedFile == null) return;

      setState(() => _isLoadingImage = true);

      final user = _auth.currentUser;
      if (user == null) {
        if (mounted) {
          setState(() => _isLoadingImage = false);
          _showSnackbar('User not authenticated', isError: true);
        }
        return;
      }

      try {
        // Read image bytes
        final bytes = await pickedFile.readAsBytes();
        
        // Convert to base64 for storage in Firestore
        final base64Image = base64Encode(bytes);
        
        print('Image converted to base64 (${bytes.length} bytes)');
        
        // Store directly in Firestore under /users/{uid}
        await _firestore.collection('users').doc(user.uid).set({
          'photoUrl': base64Image,  // Store as base64 string
          'displayName': user.displayName ?? 'User',
          'email': user.email ?? '',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          setState(() {
            _profileImageBase64 = base64Image;
            _isLoadingImage = false;
          });
          _showSnackbar('Profile image updated successfully');
          print('Profile image saved to Firestore');
        }
      } catch (uploadError) {
        if (mounted) {
          setState(() => _isLoadingImage = false);
          print('Upload error details: $uploadError');
          _showSnackbar('Error uploading image: ${uploadError.toString()}', isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingImage = false);
        print('Error picking image: $e');
        _showSnackbar('Error: Could not pick image', isError: true);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: ParkinoTheme.white,
              size: 20,
            ),
            const Gap(12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? ParkinoTheme.errorRed : ParkinoTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      pageBuilder: (context, animation1, animation2) {
        return ScaleTransition(
          scale: animation1,
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: ParkinoTheme.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ParkinoTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.logout_rounded,
                      color: ParkinoTheme.errorRed,
                      size: 28,
                    ),
                  ),
                  const Gap(16),
                  Text(
                    AppLocalizations.t('logout'),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(12),
                  Text(
                    AppLocalizations.t('are_you_sure_sign_out'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ParkinoTheme.darkGray,
                    ),
                  ),
                  const Gap(24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.t('cancel')),
                        ),
                      ),
                      const Gap(12),
                      Expanded(
                        child: ModernButton(
                          label: AppLocalizations.t('logout'),
                          backgroundColor: ParkinoTheme.errorRed,
                          onPressed: () {
                            // FIX: Reset slot reservation state before signing out
                            context.read<SlotReservationProvider>().resetOnLogout();
                            context.read<FirebaseAuthProvider>().signOut();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const SignInScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch language provider - this triggers rebuild when language changes
    final currentLocale = context.watch<LanguageProvider>().locale;
    
    return Scaffold(
      key: ValueKey(currentLocale),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ParkinoTheme.primaryDarkBlue.withOpacity(0.03),
              ParkinoTheme.veryLightGray,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(20),
                _buildHeader(),
                const Gap(32),
                _buildProfileCard(),
                const Gap(32),
                _buildProfileDetailsCard(),
                const Gap(32),
                _buildActionButtons(),
                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          AppLocalizations.t('profile'),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: ParkinoTheme.primaryDarkBlue,
          ),
        ),
        const Gap(4),
        Text(
          AppLocalizations.t('your_account_info'),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: ParkinoTheme.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return SlideTransition(
      position: _slideAnimation,
      child: ModernCard(
        backgroundColor: ParkinoTheme.white,
        padding: const EdgeInsets.all(24),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        shadows: ParkinoTheme.modernShadow(elevation: 10),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ParkinoTheme.goldenYellow,
                        ParkinoTheme.moderateGolden,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(60),
                    boxShadow: [
                      BoxShadow(
                        color: ParkinoTheme.goldenYellow.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _profileImageBase64 != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.memory(
                            base64Decode(_profileImageBase64!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: ParkinoTheme.primaryDarkBlue.withOpacity(0.5),
                                ),
                              );
                            },
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: ParkinoTheme.primaryDarkBlue.withOpacity(0.5),
                          ),
                        ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isLoadingImage ? null : _pickAndUploadProfileImage,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ParkinoTheme.goldenYellow,
                            ParkinoTheme.moderateGolden,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: ParkinoTheme.goldenYellow.withOpacity(0.6),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _isLoadingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ParkinoTheme.primaryDarkBlue,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: ParkinoTheme.primaryDarkBlue,
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const Gap(20),
            Text(
              _displayName ?? 'User',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            Text(
              _email ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ParkinoTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetailsCard() {
    return ModernCard(
      backgroundColor: ParkinoTheme.white,
      padding: const EdgeInsets.all(20),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      child: Column(
        children: [
          _buildProfileDetailRow(
            icon: Icons.person_outline,
            label: AppLocalizations.t('account_type'),
            value: AppLocalizations.t('premium_member'),
          ),
          const Gap(16),
          Divider(color: ParkinoTheme.mediumGray.withOpacity(0.5)),
          const Gap(16),
          _buildProfileDetailRow(
            icon: Icons.phone_outlined,
            label: AppLocalizations.t('phone'),
            value: _phone ?? 'Not provided',
          ),
          const Gap(16),
          Divider(color: ParkinoTheme.mediumGray.withOpacity(0.5)),
          const Gap(16),
          _buildProfileDetailRow(
            icon: Icons.calendar_today_outlined,
            label: AppLocalizations.t('member_since'),
            value: _memberSince ?? 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ParkinoTheme.goldenYellow.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: ParkinoTheme.goldenYellow, size: 20),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: ParkinoTheme.darkGray,
                  letterSpacing: 0.4,
                ),
              ),
              const Gap(4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModernButton(
          label: AppLocalizations.t('edit_profile').toUpperCase(),
          prefixIcon: Icons.edit_rounded,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  displayName: _displayName ?? 'User',
                  email: _email ?? '',
                  phone: _phone ?? '',
                ),
              ),
            ).then((updated) {
              // Reload data if profile was updated
              if (updated == true) {
                _loadUserData();
              }
            });
          },
        ),
        const Gap(12),
        ModernButton(
          label: AppLocalizations.t('logout').toUpperCase(),
          prefixIcon: Icons.logout_rounded,
          backgroundColor: ParkinoTheme.errorRed,
          isOutlined: false,
          onPressed: _showLogoutConfirmation,
        ),
      ],
    );
  }
}

// Export the modern version as the default
class ProfileScreen extends ProfileScreenModern {
  const ProfileScreen({super.key});
}
