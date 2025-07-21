// File: pages/loading/login_register/optimized_login_page.dart
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/register/auth_services.dart';
import 'package:pocket_eleven/firebase/register/login_data.dart';
import 'package:pocket_eleven/firebase/register/login_results.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/loading/login_register/register_page.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/action_button_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/app_title_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/gradient_background_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/loading_overlay_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/navigate_prompt_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/optimized_text_field_widget.dart';

/// **High-performance login page with shared AuthService**
///
/// Optimized for 60fps rendering with efficient state management,
/// responsive design, and unified authentication handling.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers - initialized once
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;

  // Shared authentication service
  static final AuthService _authService = AuthService();

  // State notifiers for efficient rebuilds
  late final ValueNotifier<bool> _isLoadingNotifier;
  late final ValueNotifier<String?> _errorNotifier;
  late final ValueNotifier<bool> _isFormValidNotifier;

  // Cached values for performance
  late final List<Color> _gradientColors;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeNotifiers();
    _setupValidationListener();
    _cacheGradientColors();
  }

  void _initializeControllers() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  void _initializeNotifiers() {
    _isLoadingNotifier = ValueNotifier(false);
    _errorNotifier = ValueNotifier<String?>(null);
    _isFormValidNotifier = ValueNotifier(false);
  }

  void _setupValidationListener() {
    void validateForm() {
      final isEmailValid = _validateEmail(_emailController.text) == null;
      final isPasswordValid =
          _validatePassword(_passwordController.text) == null;
      _isFormValidNotifier.value = isEmailValid && isPasswordValid;
    }

    _emailController.addListener(validateForm);
    _passwordController.addListener(validateForm);
  }

  void _cacheGradientColors() {
    _gradientColors = [
      AppColors.primaryColor,
      AppColors.primaryColor.withValues(alpha: 0.8),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          GradientBackground(
            colors: _gradientColors,
            child: _buildContent(),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isLoadingNotifier,
            builder: (context, isLoading, _) => isLoading
                ? const LoadingOverlay(message: 'Signing in...')
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.08,
              vertical: constraints.maxHeight * 0.05,
            ),
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight * 0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppTitle(
                    title: 'POCKET ELEVEN',
                    fontSize: 42,
                  ),
                  SizedBox(height: constraints.maxHeight * 0.08),
                  _buildEmailField(),
                  SizedBox(height: constraints.maxHeight * 0.025),
                  _buildPasswordField(),
                  _buildErrorMessage(),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  _buildForgotPasswordLink(),
                  SizedBox(height: constraints.maxHeight * 0.06),
                  _buildLoginButton(),
                  SizedBox(height: constraints.maxHeight * 0.04),
                  _buildRegisterPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return OptimizedTextField(
      label: 'Email Address',
      icon: Icons.email_outlined,
      controller: _emailController,
      validator: _validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField() {
    return OptimizedTextField(
      label: 'Password',
      icon: Icons.lock_outline,
      controller: _passwordController,
      validator: _validatePassword,
      isPassword: true,
    );
  }

  Widget _buildErrorMessage() {
    return ValueListenableBuilder<String?>(
      valueListenable: _errorNotifier,
      builder: (context, error, _) => error != null
          ? Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.errorColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.errorColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      error,
                      style: const TextStyle(
                        color: AppColors.errorColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: const Text(
          'Forgot Password?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isFormValidNotifier,
      builder: (context, isFormValid, _) => ActionButton(
        text: 'Sign In',
        onPressed: isFormValid ? _handleLogin : null,
        isLoading: _isLoadingNotifier,
        width: double.infinity,
        icon: Icons.login,
      ),
    );
  }

  Widget _buildRegisterPrompt() {
    return NavigationPrompt(
      icon: Icons.person_add_outlined,
      text: 'New here? Create your account',
      onTap: _navigateToRegister,
    );
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Email is required';
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(value!.trim())
        ? null
        : 'Enter a valid email address';
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    return value!.length >= 6 ? null : 'Password must be at least 6 characters';
  }

  // Event handlers
  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _setLoading(true);
    _clearError();

    try {
      final loginData = LoginData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final result = await _authService.loginUser(loginData, context);

      if (!mounted) return;

      switch (result) {
        case LoginSuccess():
          _navigateToHome();
        case LoginFailure(error: final error):
          _setError(error);
      }
    } catch (e) {
      if (mounted) _setError('Login failed. Please try again.');
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _setError('Please enter your email address first');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final success = await _authService.sendPasswordReset(email);

      if (!mounted) return;

      if (success) {
        _showSuccessMessage('Password reset email sent. Check your inbox.');
      } else {
        _setError('Email not found or failed to send reset email');
      }
    } catch (e) {
      if (mounted) _setError('Failed to send reset email. Try again.');
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const RegisterPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Helper methods for state management
  void _setLoading(bool isLoading) => _isLoadingNotifier.value = isLoading;
  void _setError(String error) => _errorNotifier.value = error;
  void _clearError() => _errorNotifier.value = null;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isLoadingNotifier.dispose();
    _errorNotifier.dispose();
    _isFormValidNotifier.dispose();
    super.dispose();
  }
}
