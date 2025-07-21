// File: pages/loading/login_register/optimized_register_page.dart
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/register/auth_services.dart';
import 'package:pocket_eleven/firebase/register/register_data.dart';
import 'package:pocket_eleven/firebase/register/register_results.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/loading/login_register/login_page.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/action_button_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/app_title_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/gradient_background_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/loading_overlay_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/navigate_prompt_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/optimized_text_field_widget.dart';
import 'package:pocket_eleven/pages/loading/login_register/widgets/password_strength_indicator_widget.dart';

/// **Main registration page with shared AuthService and optimized performance**
///
/// Features:
/// - Real-time form validation with visual feedback
/// - Password strength indicator
/// - Responsive design for all screen sizes
/// - 60fps performance with RepaintBoundary optimization
/// - Unified authentication handling with proper error management
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // Shared authentication service
  static final AuthService _authService = AuthService();

  // Efficient state management with ValueNotifier
  late final ValueNotifier<bool> _isLoading;
  late final ValueNotifier<bool> _formValid;
  late final ValueNotifier<int> _passwordStrength;
  late final ValueNotifier<String?> _errorNotifier;

  // Controllers map for easy management
  late final Map<String, TextEditingController> _controllers;

  // Form field configurations
  static const _fieldConfigs = [
    ('Club Name', Icons.sports_soccer, 'clubName'),
    ('Username', Icons.person, 'username'),
    ('Email', Icons.email, 'email'),
    ('Password', Icons.lock, 'password'),
    ('Confirm Password', Icons.lock_outline, 'confirmPassword'),
  ];

  @override
  void initState() {
    super.initState();
    _initializeState();
    _setupValidation();
  }

  void _initializeState() {
    _isLoading = ValueNotifier(false);
    _formValid = ValueNotifier(false);
    _passwordStrength = ValueNotifier(0);
    _errorNotifier = ValueNotifier<String?>(null);

    _controllers = Map.fromEntries(
      _fieldConfigs
          .map((config) => MapEntry(config.$3, TextEditingController())),
    );
  }

  void _setupValidation() {
    void updateValidation() {
      final hasAllFields = _controllers.values
          .every((controller) => controller.text.trim().isNotEmpty);
      final isFormValid = _validateAllFields();

      _formValid.value = hasAllFields && isFormValid;
      _clearError(); // Clear error when user starts typing
    }

    for (final entry in _controllers.entries) {
      entry.value.addListener(() {
        updateValidation();
        if (entry.key == 'password') {
          _passwordStrength.value =
              _calculatePasswordStrength(entry.value.text);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        colors: const [
          AppColors.primaryColor,
          AppColors.secondaryColor,
          AppColors.accentColor,
        ],
        child: SafeArea(
          child: Stack(
            children: [
              _buildContent(),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) => isLoading
                    ? const LoadingOverlay(
                        message: 'Creating your account...',
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(context),
              vertical: 24,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const AppTitle(
                    title: 'POCKET ELEVEN',
                    fontSize: 42,
                    letterSpacing: 3,
                  ),
                  const SizedBox(height: 48),
                  ..._buildFormFields(),
                  const SizedBox(height: 16),
                  _buildPasswordStrength(),
                  _buildErrorMessage(),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildLoginPrompt(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return _fieldConfigs.map((config) {
      final (label, icon, key) = config;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: OptimizedTextField(
          label: label,
          icon: icon,
          controller: _controllers[key]!,
          isPassword: key.contains('password'),
          keyboardType:
              key == 'email' ? TextInputType.emailAddress : TextInputType.text,
          validator: _getValidator(key),
        ),
      );
    }).toList();
  }

  Widget _buildPasswordStrength() {
    return ValueListenableBuilder<int>(
      valueListenable: _passwordStrength,
      builder: (context, strength, _) {
        if (_controllers['password']!.text.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PasswordStrengthIndicator(
            strength: strength,
            password: _controllers['password']!.text,
          ),
        );
      },
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

  Widget _buildRegisterButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _formValid,
      builder: (context, isValid, _) => ActionButton(
        text: 'Create Account',
        onPressed: isValid ? _handleRegister : null,
        isLoading: _isLoading,
        width: double.infinity,
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return NavigationPrompt(
      icon: Icons.login,
      text: "Already have an account? Sign in",
      onTap: _navigateToLogin,
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _setLoading(true);
    _clearError();

    try {
      final registerData = RegisterData(
        email: _controllers['email']!.text.trim(),
        password: _controllers['password']!.text,
        username: _controllers['username']!.text.trim(),
        clubName: _controllers['clubName']!.text.trim(),
      );

      final result = await _authService.registerUser(registerData, context);

      if (!mounted) return;

      switch (result) {
        case RegisterSuccess():
          _navigateToHome();
        case RegisterFailure(error: final error, code: final code):
          _setError(error);

          // Handle specific error cases
          if (code == 'email-already-in-use') {
            _showAlternativeAction(
                'This email is already registered. Would you like to sign in instead?');
          }
      }
    } catch (e) {
      if (mounted) _setError('Registration failed. Please try again.');
    } finally {
      if (mounted) _setLoading(false);
    }
  }

  void _showAlternativeAction(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Account Exists'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stay Here'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin();
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
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

  String? Function(String?) _getValidator(String key) {
    final validators = {
      'clubName': _validateClubName,
      'username': _validateUsername,
      'email': _validateEmail,
      'password': _validatePassword,
      'confirmPassword': _validateConfirmPassword,
    };
    return validators[key] ?? (_) => null;
  }

  static String? _validateClubName(String? value) =>
      _validateLength(value, 3, 30, 'Club name');

  static String? _validateUsername(String? value) {
    final lengthError = _validateLength(value, 3, 20, 'Username');
    if (lengthError != null) return lengthError;

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value!.trim())) {
      return 'Only letters, numbers, and underscores allowed';
    }
    return null;
  }

  static String? _validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Email is required';

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please confirm your password';
    if (value != _controllers['password']?.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? _validateLength(
      String? value, int min, int max, String field) {
    if (value?.trim().isEmpty ?? true) return '$field is required';

    final length = value!.trim().length;
    if (length < min || length > max) {
      return '$field must be $min-$max characters';
    }
    return null;
  }

  bool _validateAllFields() {
    return _controllers.entries.every((entry) {
      final validator = _getValidator(entry.key);
      return validator(entry.value.text) == null;
    });
  }

  static int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[a-zA-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

    return strength;
  }

  double _getHorizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 48;
    if (width > 400) return 24;
    return 16;
  }

  // Helper methods for state management
  void _setLoading(bool isLoading) => _isLoading.value = isLoading;
  void _setError(String error) => _errorNotifier.value = error;
  void _clearError() => _errorNotifier.value = null;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _isLoading.dispose();
    _formValid.dispose();
    _passwordStrength.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }
}
