import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'sign_up_screen.dart';
import '../../navigation/main_navigation.dart';
import '../../localization/app_localizations.dart';
import '../../widgets/language_button.dart';
import '../../widgets/password_validation_widgets.dart';
import '../../widgets/modern_widgets.dart';
import '../../services/password_validation_service.dart';
import '../../providers/firebase_auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../theme/parkino_theme.dart';

/// SignInScreen - Modern authentication interface with glassmorphism
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  String? _errorMessage;

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

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimationController.forward();
    _scaleAnimationController.forward();
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
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

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(value.trim()) ? null : 'Please enter a valid email address';
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one number';
    return null;
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = context.read<FirebaseAuthProvider>();
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        _showSuccessSnackbar(AppLocalizations.t('sign_in_successful'));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? AppLocalizations.t('sign_in_failed');
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    _showForgotPasswordDialog();
  }

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
              onPressed: isLoading ? null : () async {
                final email = resetEmailController.text.trim();

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
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                  if (!mounted) return;

                  Navigator.pop(context);
                  _showSuccessSnackbar(
                    'Password reset link sent to $email\nCheck your inbox!',
                  );
                } on FirebaseAuthException catch (e) {
                  setDialogState(() {
                    isLoading = false;
                    errorMessage = e.message ?? 'Failed to send password reset email';
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.t('send_reset_link')),
            ),
          ],
        ),
      ),
    );
  }

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
    final paddingVertical = isSmallScreen ? 30.0 : 60.0;

    return Scaffold(
      // Use locale in key to ensure complete widget rebuild
      key: ValueKey(currentLocale),
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

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(30),
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
              AppLocalizations.t('sign_in_welcome'),
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
            const SizedBox(height: 20),
            _buildFormOptions(),
            const SizedBox(height: 30),
            _buildSignInButton(),
          ],
        ),
      ),
    );
  }

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
                  AppLocalizations.t('remember_me'),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: _handleForgotPassword,
          child: Text(AppLocalizations.t('forgot_password')),
        ),
      ],
    );
  }

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
          : Text(AppLocalizations.t('sign_in')),
    );
  }

  Widget _buildFooterLinks() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Text(
                AppLocalizations.t('dont_have_account'),
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
              child: Text(
                AppLocalizations.t('create_account'),
                style: const TextStyle(
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
