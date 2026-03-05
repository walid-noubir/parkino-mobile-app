import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/password_validation_service.dart';
import '../../widgets/password_validation_widgets.dart';
import '../../localization/app_localizations.dart';

/// Password reset screen
/// Displayed when user clicks the password reset link from their email
/// Allows user to set a new password with validation
class PasswordResetScreen extends StatefulWidget {
  final String oobCode;

  const PasswordResetScreen({
    super.key,
    required this.oobCode,
  });

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen>
    with TickerProviderStateMixin {
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _verifyResetCode();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  /// Verify if the reset code is valid (optional - only check when resetting)
  /// Commenting this out because some devices have issues with verifyPasswordResetCode
  /// Firebase will validate the code when we call confirmPasswordReset
  Future<void> _verifyResetCode() async {
    try {
      final userEmail = await FirebaseAuth.instance
          .verifyPasswordResetCode(widget.oobCode);
      setState(() {
        _userEmail = userEmail;
        debugPrint('✅ Reset code verified for: $userEmail');
      });
    } on FirebaseAuthException catch (e) {
      // Don't show error here, let user try to reset anyway
      // Firebase will validate when confirmPasswordReset is called
      debugPrint('⚠️ Could not verify code at startup: ${e.message}');
      // Set a generic email to show the form
      setState(() {
        _userEmail = 'your account';
      });
    } catch (e) {
      debugPrint('⚠️ Error verifying code: $e');
      setState(() {
        _userEmail = 'your account';
      });
    }
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  /// Submit new password
  Future<void> _resetPassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validate passwords match
    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    // Validate password meets requirements
    final validationError =
        PasswordValidationService.getValidationError(password);
    if (validationError != null) {
      setState(() {
        _errorMessage = validationError;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode,
        newPassword: password,
      );

      if (!mounted) return;

      // Show success message
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message ?? 'Failed to reset password';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Password Reset Successful! ✅'),
        content: const Text(
          'Your password has been updated successfully.\nYou can now sign in with your new password.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/signin');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryDarkBlue,
            ),
            child: const Text('Go to Sign In'),
          ),
        ],
      ),
    );
  }

  bool _isPasswordValid() {
    return PasswordValidationService.meetsMinimumRequirements(
      _passwordController.text,
    );
  }

  bool _passwordsMatch() {
    return _passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Always show the reset form (don't block with error at startup)
    // Firebase will validate the code when we submit
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  _buildHeader(),
                  const SizedBox(height: 50),
                  _buildFormCard(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/parkino_logo.png',
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        const Text(
          'Reset Password',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _primaryDarkBlue,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Create a new secure password',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_userEmail != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Resetting password for: $_userEmail',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(8),
                border: const Border(
                  left: BorderSide(
                    color: Color(0xFFD32F2F),
                    width: 4,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outlined,
                    color: Color(0xFFD32F2F),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage ?? '',
                      style: const TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildPasswordField(),
          const SizedBox(height: 8),
          PasswordStrengthIndicator(
            password: _passwordController.text,
          ),
          const SizedBox(height: 12),
          PasswordRequirementsWidget(
            password: _passwordController.text,
          ),
          const SizedBox(height: 24),
          _buildConfirmPasswordField(),
          const SizedBox(height: 8),
          _buildPasswordMatchIndicator(),
          const SizedBox(height: 32),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'New Password',
        hintText: 'Enter a strong password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      obscureText: _obscureConfirmPassword,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        hintText: 'Re-enter your password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_off
                : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildPasswordMatchIndicator() {
    final isMatch = _passwordsMatch();
    final isEmpty = _passwordController.text.isEmpty;

    if (isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMatch ? Colors.green.shade300 : Colors.grey.shade300,
            border: Border.all(
              color:
                  isMatch ? Colors.green.shade700 : Colors.grey.shade600,
              width: 1.5,
            ),
          ),
          child: isMatch
              ? Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.green.shade700,
                )
              : Icon(
                  Icons.close,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Passwords match',
            style: TextStyle(
              fontSize: 12,
              color: isMatch ? Colors.green.shade900 : Colors.grey[700],
              fontWeight: isMatch ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton() {
    final isValid = _isPasswordValid() && _passwordsMatch();

    return ElevatedButton(
      onPressed: isValid && !_isLoading ? _resetPassword : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: _primaryDarkBlue,
        disabledBackgroundColor: Colors.grey.shade400,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
