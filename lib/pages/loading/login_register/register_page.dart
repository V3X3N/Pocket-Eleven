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

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  static final _authService = AuthService();

  late final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  late final ValueNotifier<bool> _formValid = ValueNotifier(false);
  late final ValueNotifier<int> _passwordStrength = ValueNotifier(0);
  late final ValueNotifier<String?> _error = ValueNotifier(null);

  late final Map<String, TextEditingController> _controllers = {
    for (final field in [
      'clubName',
      'username',
      'email',
      'password',
      'confirmPassword'
    ])
      field: TextEditingController()
  };

  static const _fields = [
    ('Club Name', Icons.sports_soccer, 'clubName'),
    ('Username', Icons.person, 'username'),
    ('Email', Icons.email, 'email'),
    ('Password', Icons.lock, 'password'),
    ('Confirm Password', Icons.lock_outline, 'confirmPassword'),
  ];

  @override
  void initState() {
    super.initState();
    _controllers.forEach((key, controller) {
      controller.addListener(() {
        _formValid.value = _validateAll();
        _error.value = null;
        if (key == 'password') {
          _passwordStrength.value = _calcStrength(controller.text);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).size.width > 600
        ? 48.0
        : MediaQuery.of(context).size.width > 400
            ? 24.0
            : 16.0;

    return Scaffold(
      body: GradientBackground(
        colors: const [
          AppColors.primaryColor,
          AppColors.secondaryColor,
          AppColors.accentColor
        ],
        child: SafeArea(
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                          horizontal: padding, vertical: 24),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            const AppTitle(
                                title: 'POCKET ELEVEN',
                                fontSize: 42,
                                letterSpacing: 3),
                            const SizedBox(height: 48),
                            ..._buildFields(),
                            const SizedBox(height: 16),
                            _buildPasswordStrength(),
                            _buildError(),
                            const SizedBox(height: 32),
                            _buildRegisterButton(),
                            const SizedBox(height: 24),
                            NavigationPrompt(
                              icon: Icons.login,
                              text: "Already have an account? Sign in",
                              onTap: _navigateToLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (_, loading, __) => loading
                    ? const LoadingOverlay(message: 'Creating your account...')
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFields() => _fields.map((field) {
        final (label, icon, key) = field;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: OptimizedTextField(
            label: label,
            icon: icon,
            controller: _controllers[key]!,
            isPassword: key.contains('password'),
            keyboardType: key == 'email'
                ? TextInputType.emailAddress
                : TextInputType.text,
            validator: (value) => _validate(key, value),
          ),
        );
      }).toList();

  Widget _buildPasswordStrength() => ValueListenableBuilder<int>(
        valueListenable: _passwordStrength,
        builder: (_, strength, __) => _controllers['password']!.text.isEmpty
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PasswordStrengthIndicator(
                  strength: strength,
                  password: _controllers['password']!.text,
                ),
              ),
      );

  Widget _buildError() => ValueListenableBuilder<String?>(
        valueListenable: _error,
        builder: (_, error, __) => error == null
            ? const SizedBox.shrink()
            : Container(
                margin: const EdgeInsets.only(top: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        child: Text(error,
                            style: const TextStyle(
                                color: AppColors.errorColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500))),
                  ],
                ),
              ),
      );

  Widget _buildRegisterButton() => ValueListenableBuilder<bool>(
        valueListenable: _formValid,
        builder: (_, valid, __) => ActionButton(
          text: 'Create Account',
          onPressed: valid ? _handleRegister : null,
          isLoading: _isLoading,
          width: double.infinity,
        ),
      );

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;
    _error.value = null;

    try {
      final result = await _authService.registerUser(
        RegisterData(
          email: _controllers['email']!.text.trim(),
          password: _controllers['password']!.text,
          username: _controllers['username']!.text.trim(),
          clubName: _controllers['clubName']!.text.trim(),
        ),
        context,
      );

      if (!mounted) return;

      switch (result) {
        case RegisterSuccess():
          _navigateToHome();
        case RegisterFailure(error: final error, code: final code):
          _error.value = error;
          if (code == 'email-already-in-use') _showEmailExistsDialog();
      }
    } catch (e) {
      if (mounted) _error.value = 'Registration failed. Please try again.';
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  void _showEmailExistsDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Account Exists'),
        content: const Text(
            'This email is already registered. Would you like to sign in instead?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Stay Here')),
          FilledButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToLogin();
              },
              child: const Text('Sign In')),
        ],
      ),
    );
  }

  void _navigateToLogin() => Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: animation.drive(
              Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic))),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ));

  void _navigateToHome() => Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HomePage(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ));

  String? _validate(String key, String? value) {
    final trimmed = value?.trim() ?? '';

    switch (key) {
      case 'clubName':
        return _validateLength(trimmed, 3, 30, 'Club name');
      case 'username':
        final lengthError = _validateLength(trimmed, 3, 20, 'Username');
        if (lengthError != null) return lengthError;
        return RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)
            ? null
            : 'Only letters, numbers, and underscores allowed';
      case 'email':
        if (trimmed.isEmpty) return 'Email is required';
        return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(trimmed)
            ? null
            : 'Please enter a valid email address';
      case 'password':
        if (value?.isEmpty ?? true) return 'Password is required';
        return value!.length >= 8
            ? null
            : 'Password must be at least 8 characters';
      case 'confirmPassword':
        if (value?.isEmpty ?? true) return 'Please confirm your password';
        return value == _controllers['password']?.text
            ? null
            : 'Passwords do not match';
      default:
        return null;
    }
  }

  String? _validateLength(String value, int min, int max, String field) {
    if (value.isEmpty) return '$field is required';
    final length = value.length;
    return (length >= min && length <= max)
        ? null
        : '$field must be $min-$max characters';
  }

  bool _validateAll() =>
      _controllers.entries
          .every((e) => _validate(e.key, e.value.text) == null) &&
      _controllers.values.every((c) => c.text.trim().isNotEmpty);

  int _calcStrength(String password) {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[a-zA-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return strength;
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var n in [_isLoading, _formValid, _passwordStrength, _error]) {
      n.dispose();
    }
    super.dispose();
  }
}
