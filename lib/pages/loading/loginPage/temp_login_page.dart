import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/loading/loginPage/login_auth_services.dart';
import 'package:pocket_eleven/pages/loading/registerPage/temp_register_page.dart';

class TempLoginPage extends StatefulWidget {
  const TempLoginPage({super.key});

  @override
  State<TempLoginPage> createState() => _TempLoginPageState();
}

class _TempLoginPageState extends State<TempLoginPage> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final GlobalKey<FormState> _formKey;
  late final AuthService _authService;

  bool _isLoading = false;
  String? _errorMessage;

  // Validation states for visual feedback
  final Map<String, bool> _validationStates = {
    'email': false,
    'password': false,
  };

  // Cached values for performance
  late final MediaQueryData _mediaQuery;
  late final double _screenWidth;
  late final double _screenHeight;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _authService = AuthService();

    // Setup optimized listeners for validation
    _usernameController.addListener(() => _updateValidation('email'));
    _passwordController.addListener(() => _updateValidation('password'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mediaQuery = MediaQuery.of(context);
    _screenWidth = _mediaQuery.size.width;
    _screenHeight = _mediaQuery.size.height;
  }

  void _updateValidation(String field) {
    final newState = _getValidationState(field);
    if (_validationStates[field] != newState) {
      setState(() {
        _validationStates[field] = newState;
      });
    }
  }

  bool _getValidationState(String field) {
    switch (field) {
      case 'email':
        return _validateEmail(_usernameController.text) == null;
      case 'password':
        return _validatePassword(_passwordController.text) == null;
      default:
        return false;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _screenWidth * 0.08,
          vertical: _screenHeight * 0.05,
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _GameTitle(),
                SizedBox(height: _screenHeight * 0.08),
                _buildInputField(
                  "Email",
                  _usernameController,
                  Icons.email,
                  'email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: _screenHeight * 0.025),
                _buildInputField(
                  "Password",
                  _passwordController,
                  Icons.lock,
                  'password',
                  isPassword: true,
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: _screenHeight * 0.03),
                  _ErrorMessage(message: _errorMessage!),
                ],
                SizedBox(height: _screenHeight * 0.06),
                _buildLoginButton(),
                SizedBox(height: _screenHeight * 0.04),
                const _RegisterPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hintText,
    TextEditingController controller,
    IconData icon,
    String validationKey, {
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final hasText = controller.text.isNotEmpty;
    final isValid = _validationStates[validationKey] ?? false;
    final borderColor =
        hasText ? (isValid ? Colors.green : Colors.red) : Colors.white70;

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: hasText
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          enabled: !_isLoading,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.8)),
            suffixIcon: hasText
                ? AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      isValid ? Icons.check_circle : Icons.error,
                      color: isValid ? Colors.green : Colors.red,
                      key: ValueKey(isValid),
                    ),
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.15),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
          ),
          validator: (value) => _getValidator(validationKey)(value),
        ),
      ),
    );
  }

  String? Function(String?) _getValidator(String key) {
    switch (key) {
      case 'email':
        return _validateEmail;
      case 'password':
        return _validatePassword;
      default:
        return (_) => null;
    }
  }

  Widget _buildLoginButton() {
    final isFormValid = _validationStates.values.every((valid) => valid);

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (_isLoading || !isFormValid) ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: isFormValid ? Colors.white : Colors.grey,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: isFormValid ? 8 : 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                )
              : Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isFormValid ? AppColors.primaryColor : Colors.white54,
                  ),
                ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value.trim())) {
      return 'Please enter a valid email address';
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await _authService.signInUser(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

// Stateless widgets for better performance
class _GameTitle extends StatelessWidget {
  const _GameTitle();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.white70, Colors.white54],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'POCKET ELEVEN',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.transparent],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;

  const _ErrorMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterPrompt extends StatelessWidget {
  const _RegisterPrompt();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TempRegisterPage()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.4), width: 1.5),
            borderRadius: BorderRadius.circular(25),
            color: Colors.white.withValues(alpha: 0.1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                "New here? Register now!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
