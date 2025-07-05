import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/pages/loading/temp_register_page.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class TempLoginPage extends StatefulWidget {
  const TempLoginPage({super.key});

  @override
  State<TempLoginPage> createState() => _TempLoginPageState();
}

class _TempLoginPageState extends State<TempLoginPage> {
  // Use late final for controllers to avoid recreation
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;

  // Cache expensive objects
  late final OutlineInputBorder _inputBorder;

  // State management
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();

    // Cache the border to avoid recreation
    _inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.white),
    );
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    return SafeArea(
      child: SingleChildScrollView(
        // Prevent overflow and improve UX
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom,
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Use RepaintBoundary for static content
                  const RepaintBoundary(child: _GameTitle()),
                  const SizedBox(height: 50),
                  _buildLoginForm(),
                  const SizedBox(height: 20),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            _buildErrorMessage(),
            const SizedBox(height: 20),
          ],
          _buildInputField(
            "Email",
            _usernameController,
            validator: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            "Password",
            _passwordController,
            isPassword: true,
            validator: _validatePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 50),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
  }) {
    return RepaintBoundary(
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        obscureText: isPassword && _obscurePassword,
        inputFormatters: isPassword
            ? null
            : [
                FilteringTextInputFormatter.deny(
                    RegExp(r'\s')), // No spaces for email
              ],
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          enabledBorder: _inputBorder,
          focusedBorder: _inputBorder,
          errorBorder: _inputBorder.copyWith(
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: _inputBorder.copyWith(
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorStyle: const TextStyle(color: Colors.red),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          final screenSize = MediaQuery.of(context).size;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: OptionButton(
              index: 0,
              text: _isLoading ? 'Signing in...' : 'Sign in',
              onTap: _isLoading ? null : _handleLogin,
              screenWidth: screenSize.width,
              screenHeight: screenSize.height,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegisterLink() {
    return RepaintBoundary(
      child: InkWell(
        onTap: _isLoading ? null : _navigateToRegister,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "New here? Register now!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: _isLoading ? Colors.white60 : Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Event handlers with comprehensive error handling
  Future<void> _handleLogin() async {
    try {
      // Clear previous error
      if (_errorMessage != null) {
        setState(() {
          _errorMessage = null;
        });
      }

      // Validate form
      if (!_formKey.currentState!.validate()) {
        return;
      }

      // Show loading state
      setState(() {
        _isLoading = true;
      });

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Attempt login
      await AuthServices.signinUser(
        _usernameController.text.trim(),
        _passwordController.text,
        context,
      );

      // Check if widget is still mounted
      if (!mounted) return;

      // Navigate to home page
      await Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      // Handle specific error types
      String errorMessage = 'An unexpected error occurred';

      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format.';
      } else if (e.toString().contains('user-not-found')) {
        errorMessage = 'No account found with this email.';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password.';
      } else if (e.toString().contains('user-disabled')) {
        errorMessage = 'This account has been disabled.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many attempts. Please try again later.';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = errorMessage;
        });

        // Haptic feedback for error
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _navigateToRegister() {
    try {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const TempRegisterPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
              ),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } catch (e) {
      // Fallback navigation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TempRegisterPage()),
      );
    }
  }
}

// Extracted as a separate stateless widget for better performance
class _GameTitle extends StatelessWidget {
  const _GameTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'POCKET',
          style: TextStyle(
            fontSize: 44.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'ELEVEN',
          style: TextStyle(
            fontSize: 44.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
