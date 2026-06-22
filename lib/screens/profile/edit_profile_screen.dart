import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gap/gap.dart';
import '../../localization/app_localizations.dart';
import '../../providers/language_provider.dart';
import '../../theme/parkino_theme.dart';
import '../../widgets/modern_widgets.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String displayName;
  final String email;
  final String phone;

  const EditProfileScreen({
    super.key,
    required this.displayName,
    required this.email,
    required this.phone,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = false;
  bool _isEdited = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.displayName);
    _emailController = TextEditingController(text: widget.email);
    _phoneController = TextEditingController(text: widget.phone);

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();

    // Listen to changes to enable/disable save button
    _displayNameController.addListener(_checkChanges);
    _emailController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
  }

  void _checkChanges() {
    setState(() {
      _isEdited = _displayNameController.text != widget.displayName ||
          _emailController.text != widget.email ||
          _phoneController.text != widget.phone;
    });
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    // Validate inputs
    if (_displayNameController.text.isEmpty) {
      _showError('Display name cannot be empty');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showError('Email cannot be empty');
      return;
    }
    if (_phoneController.text.isEmpty) {
      _showError('Phone cannot be empty');
      return;
    }

    setState(() => _isLoading = true);
    _errorMessage = null;

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showError('User not authenticated');
        return;
      }

      // If email changed, update Firebase Auth email
      if (_emailController.text != widget.email) {
        try {
          await user.verifyBeforeUpdateEmail(_emailController.text);
          print('Verification email sent to: ${_emailController.text}');
          _showSnackbar(
            'Verification email sent. Please verify to complete email change.',
            isSuccess: false,
          );
        } catch (e) {
          print('Error updating email: $e');
          _showError('Email already in use or invalid');
          setState(() => _isLoading = false);
          return;
        }
      }

      // Update Firestore document
      await _firestore.collection('users').doc(user.uid).set({
        'displayName': _displayNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print(' Profile updated successfully in Firestore');

      // Update Firebase Auth display name
      await user.updateDisplayName(_displayNameController.text);

      if (mounted) {
        _showSnackbar('Profile updated successfully!', isSuccess: true);
        setState(() => _isLoading = false);

        // Return to previous screen after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop(true); // true = data was updated
        }
      }
    } catch (e) {
      print(' Error saving profile: $e');
      _showError('Failed to save changes: ${e.toString()}');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: ParkinoTheme.white,
              size: 20,
            ),
            const Gap(12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ParkinoTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSnackbar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: ParkinoTheme.white,
              size: 20,
            ),
            const Gap(12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isSuccess ? ParkinoTheme.successGreen : ParkinoTheme.infoBlue,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch language provider
    context.watch<LanguageProvider>().locale;

    return Scaffold(
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(12),
                        splashColor:
                            ParkinoTheme.goldenYellow.withOpacity(0.1),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ParkinoTheme.goldenYellow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_rounded,
                            color: ParkinoTheme.primaryDarkBlue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.t('edit_profile'),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const Spacer(),
                    SizedBox(width: 44), // Balance the back button
                  ],
                ),
                const Gap(32),

                // Form Fields
                _buildEditField(
                  label: AppLocalizations.t('display_name'),
                  controller: _displayNameController,
                  icon: Icons.person_outline,
                  hint: AppLocalizations.t('display_name'),
                ),
                const Gap(20),
                _buildEditField(
                  label: AppLocalizations.t('email_address'),
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  hint: AppLocalizations.t('email_address'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const Gap(20),
                _buildEditField(
                  label: AppLocalizations.t('phone_number'),
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  hint: AppLocalizations.t('phone_number'),
                  keyboardType: TextInputType.phone,
                ),
                const Gap(32),

                // Error message if any
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ParkinoTheme.errorRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ParkinoTheme.errorRed.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_rounded,
                          color: ParkinoTheme.errorRed,
                          size: 20,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: ParkinoTheme.errorRed,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                ],

                // Save Button
                ModernButton(
                  label: _isLoading ? AppLocalizations.t('loading') : AppLocalizations.t('save_changes'),
                  onPressed: (_isLoading || !_isEdited)
                      ? () {}
                      : () {
                          _saveChanges();
                        },
                  backgroundColor: _isEdited && !_isLoading
                      ? ParkinoTheme.goldenYellow
                      : ParkinoTheme.mediumGray,
                  textColor: ParkinoTheme.primaryDarkBlue,
                ),
                const Gap(12),

                // Cancel Button
                OutlinedButton(
                  onPressed: _isLoading ? () {} : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: ParkinoTheme.errorRed,
                    side: const BorderSide(
                      color: ParkinoTheme.errorRed,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.t('cancel'),
                    style: const TextStyle(
                      color: ParkinoTheme.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
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

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ParkinoTheme.darkGray,
            letterSpacing: 0.4,
          ),
        ),
        const Gap(8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: ParkinoTheme.goldenYellow, size: 20),
            filled: true,
            fillColor: ParkinoTheme.veryLightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: ParkinoTheme.mediumGray.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ParkinoTheme.goldenYellow,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            fontSize: 14,
            color: ParkinoTheme.primaryDarkBlue,
          ),
        ),
      ],
    );
  }
}
