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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  static final _authService = AuthService();

  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();

  late final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  late final ValueNotifier<String?> _error = ValueNotifier(null);
  late final ValueNotifier<bool> _formValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    void validateForm() {
      _formValid.value = _validate('email', _emailController.text) == null &&
          _validate('password', _passwordController.text) == null &&
          _emailController.text.trim().isNotEmpty &&
          _passwordController.text.trim().isNotEmpty;
      _error.value = null;
    }

    _emailController.addListener(validateForm);
    _passwordController.addListener(validateForm);
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
                            _buildEmailField(),
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                            _buildError(),
                            const SizedBox(height: 32),
                            _buildLoginButton(),
                            const SizedBox(height: 24),
                            NavigationPrompt(
                              icon: Icons.person_add_outlined,
                              text: "New here? Create your account",
                              onTap: _navigateToRegister,
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
                    ? const LoadingOverlay(message: 'Signing in...')
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() => OptimizedTextField(
        label: 'Email Address',
        icon: Icons.email,
        controller: _emailController,
        validator: (value) => _validate('email', value),
        keyboardType: TextInputType.emailAddress,
      );

  Widget _buildPasswordField() => OptimizedTextField(
        label: 'Password',
        icon: Icons.lock,
        controller: _passwordController,
        validator: (value) => _validate('password', value),
        isPassword: true,
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

  Widget _buildLoginButton() => ValueListenableBuilder<bool>(
        valueListenable: _formValid,
        builder: (_, valid, __) => ActionButton(
          text: 'Sign In',
          onPressed: valid ? _handleLogin : null,
          isLoading: _isLoading,
          width: double.infinity,
        ),
      );

  String? _validate(String field, String? value) {
    final trimmed = value?.trim() ?? '';
    switch (field) {
      case 'email':
        if (trimmed.isEmpty) return 'Email is required';
        return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                .hasMatch(trimmed)
            ? null
            : 'Please enter a valid email address';
      case 'password':
        if (value?.isEmpty ?? true) return 'Password is required';
        return value!.length >= 6
            ? null
            : 'Password must be at least 6 characters';
      default:
        return null;
    }
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _isLoading.value = true;
    _error.value = null;

    try {
      final result = await _authService.loginUser(
        LoginData(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
        context,
      );

      if (!mounted) return;

      switch (result) {
        case LoginSuccess():
          _navigateToHome();
        case LoginFailure(error: final error):
          _error.value = error;
      }
    } catch (e) {
      if (mounted) _error.value = 'Login failed. Please try again.';
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  void _navigateToRegister() => Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const RegisterPage(),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
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

  @override
  void dispose() {
    for (var c in [_emailController, _passwordController]) {
      c.dispose();
    }
    for (var n in [_isLoading, _error, _formValid]) {
      n.dispose();
    }
    super.dispose();
  }
}
