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
  final _formKey = GlobalKey<FormState>();
  final _registerService = RegisterService();

  // Use ValueNotifier for efficient state management
  final _isLoading = ValueNotifier<bool>(false);
  final _formValid = ValueNotifier<bool>(false);
  final _passwordStrength = ValueNotifier<int>(0);

  // Controllers
  final _controllers = <String, TextEditingController>{
    'clubName': TextEditingController(),
    'username': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'confirmPassword': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _setupValidation();
  }

  void _setupValidation() {
    void updateValidation() {
      _formValid.value = _controllers.values
              .every((controller) => controller.text.trim().isNotEmpty) &&
          _validateForm();
    }

    _controllers.forEach((key, controller) {
      controller.addListener(() {
        updateValidation();
        if (key == 'password') {
          _passwordStrength.value = _calculatePasswordStrength(controller.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    _isLoading.dispose();
    _formValid.dispose();
    _passwordStrength.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: SafeArea(
          child: ValueListenableBuilder<bool>(
            valueListenable: _isLoading,
            builder: (context, isLoading, _) =>
                isLoading ? const _LoadingOverlay() : _buildContent(),
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
            padding: const EdgeInsets.all(24),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const _GameTitle(),
                  const SizedBox(height: 48),
                  ..._buildInputFields(),
                  const SizedBox(height: 24),
                  _buildPasswordStrength(),
                  const SizedBox(height: 32),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  const _LoginPrompt(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInputFields() {
    final fields = [
      ('Club Name', Icons.sports_soccer, 'clubName'),
      ('Username', Icons.person, 'username'),
      ('Email', Icons.email, 'email'),
      ('Password', Icons.lock, 'password'),
      ('Confirm Password', Icons.lock_outline, 'confirmPassword'),
    ];

    return fields
        .map((field) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _OptimizedTextField(
                label: field.$1,
                icon: field.$2,
                controller: _controllers[field.$3]!,
                isPassword: field.$3.contains('password'),
                keyboardType: field.$3 == 'email'
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                validator: _getValidator(field.$3),
              ),
            ))
        .toList();
  }

  Widget _buildPasswordStrength() {
    return ValueListenableBuilder<int>(
      valueListenable: _passwordStrength,
      builder: (context, strength, _) {
        if (_controllers['password']!.text.isEmpty)
          return const SizedBox.shrink();

        final colors = [Colors.red, Colors.orange, Colors.yellow, Colors.green];
        final labels = ['Weak', 'Fair', 'Good', 'Strong'];
        final color = colors[strength.clamp(0, 3)];

        return RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Password Strength: ${labels[strength.clamp(0, 3)]}',
                  style: TextStyle(
                      color: color, fontSize: 14, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: strength / 4,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegisterButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: _formValid,
      builder: (context, isValid, _) => RepaintBoundary(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isValid ? _handleRegister : null,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isValid ? Colors.white : Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: isValid ? 8 : 0,
            ),
            child: ValueListenableBuilder<bool>(
              valueListenable: _isLoading,
              builder: (context, loading, _) => loading
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
                            isValid ? AppColors.primaryColor : Colors.white54,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    _isLoading.value = true;

    try {
      final registerData = RegisterData(
        email: _controllers['email']!.text.trim(),
        password: _controllers['password']!.text,
        username: _controllers['username']!.text.trim(),
        clubName: _controllers['clubName']!.text.trim(),
      );

      final result = await _registerService.registerUser(registerData, context);

      if (mounted) {
        if (result is RegisterSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else if (result is RegisterFailure) {
          _showError(result.error);
        }
      }
    } catch (e) {
      if (mounted) _showError('Registration failed. Please try again.');
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String? Function(String?) _getValidator(String key) {
    final validators = {
      'clubName': (String? value) => _validateLength(value, 3, 30, 'Club name'),
      'username': (String? value) => _validateUsername(value),
      'email': (String? value) => _validateEmail(value),
      'password': (String? value) => _validatePassword(value),
      'confirmPassword': (String? value) => _validateConfirmPassword(value),
    };
    return validators[key] ?? (_) => null;
  }

  String? _validateLength(String? value, int min, int max, String field) {
    if (value?.trim().isEmpty ?? true) return '$field is required';
    final length = value!.trim().length;
    if (length < min || length > max)
      return '$field must be $min-$max characters';
    return null;
  }

  String? _validateUsername(String? value) {
    final lengthError = _validateLength(value, 3, 20, 'Username');
    if (lengthError != null) return lengthError;
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value!.trim())) {
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
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) return 'Please confirm your password';
    if (value != _controllers['password']!.text)
      return 'Passwords do not match';
    return null;
  }

  bool _validateForm() {
    return _controllers.entries.every((entry) {
      final validator = _getValidator(entry.key);
      return validator(entry.value.text) == null;
    });
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[a-zA-Z]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }
}

class _OptimizedTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?) validator;

  const _OptimizedTextField({
    required this.label,
    required this.icon,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    required this.validator,
  });

  @override
  State<_OptimizedTextField> createState() => _OptimizedTextFieldState();
}

class _OptimizedTextFieldState extends State<_OptimizedTextField> {
  final _focusNode = FocusNode();
  final _hasText = ValueNotifier<bool>(false);
  final _isValid = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
    _focusNode.addListener(_updateState);
  }

  void _updateState() {
    _hasText.value = widget.controller.text.isNotEmpty;
    _isValid.value = widget.validator(widget.controller.text) == null;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hasText.dispose();
    _isValid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ValueListenableBuilder<bool>(
        valueListenable: _hasText,
        builder: (context, hasText, _) => ValueListenableBuilder<bool>(
          valueListenable: _isValid,
          builder: (context, isValid, _) {
            final borderColor = hasText
                ? (isValid ? Colors.green : Colors.red)
                : Colors.white.withOpacity(0.3);

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: hasText
                    ? [
                        BoxShadow(
                          color: borderColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.isPassword,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon:
                      Icon(widget.icon, color: Colors.white.withOpacity(0.7)),
                  suffixIcon: hasText
                      ? Icon(
                          isValid ? Icons.check_circle : Icons.error,
                          color: isValid ? Colors.green : Colors.red,
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
                  fillColor: Colors.white.withOpacity(0.1),
                  contentPadding: const EdgeInsets.all(20),
                ),
                validator: widget.validator,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameTitle extends StatelessWidget {
  const _GameTitle();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Colors.white, Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'POCKET ELEVEN',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            width: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple, Colors.transparent],
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
      child: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TempLoginPage()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(25),
            color: Colors.white.withOpacity(0.1),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.login, color: Colors.white, size: 18),
              SizedBox(width: 8),
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
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
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
