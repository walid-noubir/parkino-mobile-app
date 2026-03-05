import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_up_screen.dart';
import '../../navigation/main_navigation.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/language_button.dart';
import '../../widgets/password_validation_widgets.dart';
import '../../services/password_validation_service.dart';
import '../../providers/firebase_auth_provider.dart';

/// SignInScreen widget for user authentication
/// 
/// Provides a complete authentication interface with email/password validation,
/// state management, and responsive design following Parkino brand guidelines.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

/// State class for SignInScreen
/// Manages form validation, authentication state, and animations
class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  // Form and Controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Form state variables
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  // Brand colors
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
  }

  /// Initialize all animation controllers and animations
  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  /// Setup focus node listeners for real-time validation feedback
  void _setupFocusListeners() {
    _emailFocusNode.addListener(() {
      setState(() {});
    });
    _passwordFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength and requirements
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Calculate password strength (0.0 to 1.0)
  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    if (password.length < 8) return 0.25;

    double strength = 0.25;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.15;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.20;

    return strength.clamp(0.0, 1.0);
  }

  /// Get password strength indicator color
  Color _getPasswordStrengthColor(double strength) {
    if (strength < 0.4) return Colors.red;
    if (strength < 0.7) return Colors.orange;
    return Colors.green;
  }

  /// Get password strength text
  String _getPasswordStrengthText(double strength) {
    if (strength < 0.4) return 'Weak';
    if (strength < 0.7) return 'Fair';
    return 'Strong';
  }

  /// Handle sign-in logic
  Future<void> _signIn() async {
    _clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<FirebaseAuthProvider>();
    authProvider.clearError();

    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      _showSuccessSnackbar('Sign in successful!');
      _navigator();
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage;
      });
    }
  }

  /// Handle forgot password action
  void _handleForgotPassword() {
    _showForgotPasswordDialog();
  }

  /// Show forgot password dialog
  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Reset Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                if (errorMessage != null) ...[
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
                            errorMessage ?? '',
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
                TextField(
                  controller: resetEmailController,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    hintText: 'Email address',
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  onChanged: (_) {
                    setDialogState(() {
                      errorMessage = null;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final email = resetEmailController.text.trim();

                      // Validate email
                      if (email.isEmpty) {
                        setDialogState(() {
                          errorMessage = 'Please enter your email address';
                        });
                        return;
                      }

                      if (!PasswordValidationService.isValidEmail(email)) {
                        setDialogState(() {
                          errorMessage = 'Please enter a valid email address';
                        });
                        return;
                      }

                      setDialogState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        // Send password reset email using Firebase
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(email: email);

                        if (!mounted) return;

                        Navigator.pop(context);
                        _showSuccessSnackbar(
                          'Password reset link sent to $email\nCheck your inbox!',
                        );
                      } on FirebaseAuthException catch (e) {
                        setDialogState(() {
                          isLoading = false;
                          errorMessage = e.message ??
                              'Failed to send password reset email';
                        });
                      } catch (e) {
                        setDialogState(() {
                          isLoading = false;
                          errorMessage = 'An error occurred. Please try again.';
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }

  /// Clear error message
  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  /// Handle authentication errors
  void _handleAuthError(String error) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: _primaryDarkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFFFC107),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Navigate to main navigation page
  void _navigator() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigation(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.height < 600;
    final paddingVertical = isSmallScreen ? 30.0 : 60.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [LanguageButton()],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: paddingVertical),
                        _buildHeader(),
                        SizedBox(height: isSmallScreen ? 30 : 50),
                        _buildFormCard(),
                        SizedBox(height: isSmallScreen ? 20 : 30),
                        _buildFooterLinks(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build header section with logo and title
  Widget _buildHeader() {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1500),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Image.asset(
                'assets/images/parkino_logo.png',
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          'Parkino',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _primaryDarkBlue,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Smart Parking Solutions',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF999999),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  /// Build form card containing all input fields
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _primaryDarkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome to Parkino',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (_errorMessage != null) ...[
              _buildErrorBanner(),
              const SizedBox(height: 16),
            ],
            _buildEmailField(),
            const SizedBox(height: 20),
            _buildPasswordField(),
            const SizedBox(height: 12),
            _buildPasswordStrengthIndicator(),
            const SizedBox(height: 12),
            _buildPasswordRequirements(),
            const SizedBox(height: 20),
            _buildFormOptions(),
            const SizedBox(height: 30),
            _buildSignInButton(),
          ],
        ),
      ),
    );
  }

  /// Build error banner
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? '',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  /// Build email input field
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.t('email'),
        hintText: AppLocalizations.t('email_hint'),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: _emailFocusNode.hasFocus
              ? const Color(0xFFFFC107)
              : Colors.grey.shade400,
        ),
      ),
      validator: _validateEmail,
      autocorrect: false,
    );
  }

  /// Build password input field
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onChanged: (value) {
        setState(() {});
      },
      onFieldSubmitted: (_) {
        if (!_isLoading) {
          _signIn();
        }
      },
      decoration: InputDecoration(
        labelText: AppLocalizations.t('password'),
        hintText: AppLocalizations.t('password_hint'),
        prefixIcon: Icon(
          Icons.lock_outlined,
          color: _passwordFocusNode.hasFocus
              ? const Color(0xFFFFC107)
              : Colors.grey.shade400,
        ),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          child: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: const Color(0xFFFFC107),
          ),
        ),
      ),
      validator: _validatePassword,
    );
  }

  /// Build password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return PasswordStrengthIndicator(
      password: _passwordController.text,
    );
  }

  /// Build password requirements checklist
  Widget _buildPasswordRequirements() {
    if (_passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    return PasswordRequirementsWidget(
      password: _passwordController.text,
    );
  }

  /// Build form options (Remember me + Forgot password)
  Widget _buildFormOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              Flexible(
                child: Text(
                  'Remember me',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _handleForgotPassword,
          child: const Text('Forgot Password?'),
        ),
      ],
    );
  }

  /// Build sign-in button
  Widget _buildSignInButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signIn,
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('Sign In'),
    );
  }

  /// Build footer links
  Widget _buildFooterLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(
                color: _primaryDarkBlue.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpScreen(),
                  ),
                );
              },
              child: const Text(
                'Create an account',
                style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
