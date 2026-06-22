import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/language_button.dart';
import '../../widgets/password_validation_widgets.dart';
import '../../services/password_validation_service.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme/parkino_theme.dart';

/// SignUpScreen widget for user registration
/// 
/// Provides a complete registration interface with username, email, phone,
/// password validation, and responsive design following Parkino brand guidelines.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

/// State class for SignUpScreen
/// Manages form validation, registration state, and animations
class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  // Form and Controllers
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Focus nodes
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Form state variables
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  // Brand colors
  static const Color _primaryDarkBlue = Color(0xFF0B2A4A);
  static const Color _goldenYellow = Color(0xFFFFC107);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initialize all animation controllers and animations
  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.easeOut),
    );

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone format
  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10,}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  /// Calculate password strength
  double _calculatePasswordStrength(String password) {
    return PasswordValidationService.calculatePasswordStrength(password);
  }

  /// Handle registration
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    final authProvider = context.read<FirebaseAuthProvider>();
    authProvider.clearError();

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      username: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      _showSuccessSnackbar('Account created successfully!');
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = authProvider.errorMessage;
      });
    }
  }

  /// Handle forgot password
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
          title: Text(AppLocalizations.t('reset_password')),
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
              child: Text(AppLocalizations.t('cancel')),
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
                  : Text(AppLocalizations.t('send_reset_link')),
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    // Watch language provider - this triggers rebuild when language changes
    final currentLocale = context.watch<LanguageProvider>().locale;
    
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.height < 600;
    final paddingVertical = isSmallScreen ? 20.0 : 30.0;

    return Scaffold(
      backgroundColor: ParkinoTheme.white,
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
                        SizedBox(height: isSmallScreen ? 20 : 30),
                        _buildFormCard(),
                        SizedBox(height: isSmallScreen ? 15 : 20),
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
                width: 130,
                height: 130,
                fit: BoxFit.contain,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Parkino',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _primaryDarkBlue,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.t('sign_up_welcome'),
          style: const TextStyle(
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: ParkinoTheme.white,
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
            Text(
              AppLocalizations.t('sign_up'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _primaryDarkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.t('join_parkino_today'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null) ...[
              _buildErrorBanner(),
              const SizedBox(height: 16),
            ],
            _buildUsernameField(),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 8),
            _buildPasswordStrengthIndicator(),
            const SizedBox(height: 12),
            _buildPasswordRequirements(),
            const SizedBox(height: 16),
            _buildConfirmPasswordField(),
            const SizedBox(height: 28),
            _buildSignUpButton(),
          ],
        ),
      ),
    );
  }

  /// Build error banner
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    );
  }

  /// Build username field
  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameController,
      focusNode: _usernameFocusNode,
      decoration: InputDecoration(
        labelText: AppLocalizations.t('username'),
        hintText: 'Choose your username',
        prefixIcon: Icon(
          Icons.person_outline,
          color: _usernameFocusNode.hasFocus
              ? const Color(0xFFFFC107)
              : Colors.grey.shade400,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${AppLocalizations.t('username')} is required';
        }
        if (value.length < 3) {
          return '${AppLocalizations.t('username')} must be at least 3 characters';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        _emailFocusNode.requestFocus();
      },
    );
  }

  /// Build email field
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: AppLocalizations.t('email'),
        hintText: 'example@parkino.com',
        prefixIcon: Icon(
          Icons.email_outlined,
          color: _emailFocusNode.hasFocus
              ? const Color(0xFFFFC107)
              : Colors.grey.shade400,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${AppLocalizations.t('email')} is required';
        }
        if (!_isValidEmail(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        _phoneFocusNode.requestFocus();
      },
    );
  }

  /// Build phone field
  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: AppLocalizations.t('phone'),
        hintText: '+1 (555) 000-0000',
        prefixIcon: Icon(
          Icons.phone_outlined,
          color: _phoneFocusNode.hasFocus
              ? const Color(0xFFFFC107)
              : Colors.grey.shade400,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '${AppLocalizations.t('phone')} is required';
        }
        if (!_isValidPhone(value)) {
          return 'Please enter a valid phone number (at least 10 digits)';
        }
        return null;
      },
      onFieldSubmitted: (_) {
        _passwordFocusNode.requestFocus();
      },
    );
  }

  /// Build password field
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      decoration: InputDecoration(
        labelText: AppLocalizations.t('password'),
        hintText: AppLocalizations.t('password_hint'),
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password is required';
        }
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
      onChanged: (_) {
        setState(() {});
      },
      onFieldSubmitted: (_) {
        _confirmPasswordFocusNode.requestFocus();
      },
    );
  }

  /// Build password strength indicator
  Widget _buildPasswordStrengthIndicator() {
    return PasswordStrengthIndicator(
      password: _passwordController.text,
    );
  }

  /// Build password requirements checklist
  Widget _buildPasswordRequirements() {
    return PasswordRequirementsWidget(
      password: _passwordController.text,
    );
  }

  /// Build confirm password field
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: AppLocalizations.t('confirm_password'),
        hintText: AppLocalizations.t('password_hint'),
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
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
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  /// Build sign-up button
  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signUp,
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(AppLocalizations.t('sign_up')),
    );
  }

  /// Build footer links
  Widget _buildFooterLinks() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              AppLocalizations.t('already_have_account'),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.t('sign_in'),
              style: const TextStyle(
                color: _primaryDarkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}
