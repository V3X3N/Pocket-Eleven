import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/loading/loginPage/temp_login_page.dart';
import 'package:pocket_eleven/pages/loading/registerPage/register_auth_services.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class TempRegisterPage extends StatefulWidget {
  const TempRegisterPage({super.key});

  @override
  State<TempRegisterPage> createState() => _TempRegisterPageState();
}

class _TempRegisterPageState extends State<TempRegisterPage> {
  // Controllers using late for better memory management
  late final TextEditingController _clubnameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  late final GlobalKey<FormState> _formKey;
  late final RegisterService _registerService;

  // Optimized state management
  bool _isLoading = false;
  final Map<String, bool> _validationStates = {
    'clubName': false,
    'username': false,
    'email': false,
    'password': false,
    'confirmPassword': false,
  };

  // Cached values for performance
  late final MediaQueryData _mediaQuery;
  late final double _screenWidth;
  late final double _screenHeight;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _formKey = GlobalKey<FormState>();
    _registerService = RegisterService();
  }

  void _initializeControllers() {
    _clubnameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Setup optimized listeners
    _clubnameController.addListener(() => _updateValidation('clubName'));
    _usernameController.addListener(() => _updateValidation('username'));
    _emailController.addListener(() => _updateValidation('email'));
    _passwordController.addListener(() {
      _updateValidation('password');
      _updateValidation('confirmPassword');
    });
    _confirmPasswordController
        .addListener(() => _updateValidation('confirmPassword'));
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
      case 'clubName':
        return _validateClubname(_clubnameController.text) == null;
      case 'username':
        return _validateUsername(_usernameController.text) == null;
      case 'email':
        return _validateEmail(_emailController.text) == null;
      case 'password':
        return _validatePassword(_passwordController.text) == null;
      case 'confirmPassword':
        return _validateConfirmPassword(_confirmPasswordController.text) ==
            null;
      default:
        return false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mediaQuery = MediaQuery.of(context);
    _screenWidth = _mediaQuery.size.width;
    _screenHeight = _mediaQuery.size.height;
  }

  @override
  void dispose() {
    _clubnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        body: _isLoading ? const _LoadingOverlay() : _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
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
                SizedBox(height: _screenHeight * 0.06),
                ..._buildInputFields(),
                SizedBox(height: _screenHeight * 0.04),
                _buildPasswordStrengthIndicator(),
                SizedBox(height: _screenHeight * 0.05),
                _buildRegisterButton(),
                SizedBox(height: _screenHeight * 0.03),
                const _LoginPrompt(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInputFields() {
    final fields = [
      _buildInputField(
          "Club Name", _clubnameController, Icons.sports_soccer, 'clubName'),
      _buildInputField(
          "Username", _usernameController, Icons.person, 'username'),
      _buildInputField("Email", _emailController, Icons.email, 'email',
          keyboardType: TextInputType.emailAddress),
      _buildInputField("Password", _passwordController, Icons.lock, 'password',
          isPassword: true),
      _buildInputField("Confirm Password", _confirmPasswordController,
          Icons.lock_outline, 'confirmPassword',
          isPassword: true),
    ];

    return fields
        .map((field) => [
              field,
              SizedBox(height: _screenHeight * 0.025),
            ])
        .expand((x) => x)
        .toList()
      ..removeLast();
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
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.15),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
          validator: (value) => _getValidator(validationKey)(value),
        ),
      ),
    );
  }

  String? Function(String?) _getValidator(String key) {
    switch (key) {
      case 'clubName':
        return _validateClubname;
      case 'username':
        return _validateUsername;
      case 'email':
        return _validateEmail;
      case 'password':
        return _validatePassword;
      case 'confirmPassword':
        return _validateConfirmPassword;
      default:
        return (_) => null;
    }
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordController.text.isEmpty) return const SizedBox.shrink();

    final strength = _calculatePasswordStrength(_passwordController.text);
    final strengthColor = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green
    ][strength.clamp(0, 3)];

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white.withValues(alpha: 0.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Strength: ${_getStrengthText(strength)}',
              style: TextStyle(
                  color: strengthColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: strength / 4,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
            ),
          ],
        ),
      ),
    );
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
        return 'Very Weak';
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Unknown';
    }
  }

  int _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[a-zA-Z]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  Widget _buildRegisterButton() {
    final isFormValid = _validationStates.values.every((valid) => valid);

    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: (_isLoading || !isFormValid) ? null : _handleRegister,
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Create Account',
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

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final registerData = RegisterData(
        email: _emailController.text,
        password: _passwordController.text,
        username: _usernameController.text,
        clubName: _clubnameController.text,
      );

      final result = await _registerService.registerUser(registerData, context);

      if (mounted) {
        if (result is RegisterSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (result is RegisterFailure) {
          _showErrorSnackbar(result.error);
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Validation methods (shortened)
  String? _validateClubname(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Club name is required';
    final trimmed = value!.trim();
    if (trimmed.length < 3 || trimmed.length > 30) {
      return 'Club name must be 3-30 characters';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Username is required';
    final trimmed = value!.trim();
    if (trimmed.length < 3 || trimmed.length > 20) {
      return 'Username must be 3-20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed)) {
      return 'Only letters, numbers, and underscores allowed';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value?.trim().isEmpty ?? true) return 'Email is required';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) return 'Password is required';
    if (value!.length < 8) return 'Password must be at least 8 characters';
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Password must contain at least one letter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }
}

// Optimized stateless widgets
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

class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TempLoginPage()),
        ),
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
              Icon(Icons.login, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text(
                "Already have an account? Sign in",
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

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Creating your account...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
