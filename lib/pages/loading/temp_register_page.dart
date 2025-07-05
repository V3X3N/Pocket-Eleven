import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/firebase/firebase_club.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';
import 'package:pocket_eleven/pages/loading/temp_login_page.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class TempRegisterPage extends StatefulWidget {
  const TempRegisterPage({super.key});

  @override
  State<TempRegisterPage> createState() => _TempRegisterPageState();
}

class _TempRegisterPageState extends State<TempRegisterPage> {
  // Use late final for controllers to avoid recreation
  late final TextEditingController _clubnameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final GlobalKey<FormState> _formKey;
  late final ScrollController _scrollController;

  // Cache expensive objects
  late final OutlineInputBorder _inputBorder;
  late final OutlineInputBorder _errorBorder;
  late final OutlineInputBorder _focusedErrorBorder;

  // State management
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  double _registrationProgress = 0.0;
  String _progressMessage = '';

  // Input validation state
  final Map<String, bool> _fieldValidationState = {
    'clubname': false,
    'username': false,
    'email': false,
    'password': false,
    'confirmPassword': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeBorders();
    _scrollController = ScrollController();
  }

  void _initializeControllers() {
    _clubnameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _formKey = GlobalKey<FormState>();

    // Add listeners for real-time validation
    _clubnameController.addListener(() => _validateField('clubname'));
    _usernameController.addListener(() => _validateField('username'));
    _emailController.addListener(() => _validateField('email'));
    _passwordController.addListener(() => _validateField('password'));
    _confirmPasswordController
        .addListener(() => _validateField('confirmPassword'));
  }

  void _initializeBorders() {
    _inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.white),
    );
    _errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.red),
    );
    _focusedErrorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    );
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    _clubnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
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
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Use RepaintBoundary for static content
                  const RepaintBoundary(child: _GameTitle()),
                  const SizedBox(height: 30),
                  if (_isLoading) _buildProgressIndicator(),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _buildRegistrationForm(),
                  ),
                  const SizedBox(height: 20),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return RepaintBoundary(
      child: Column(
        children: [
          LinearProgressIndicator(
            value: _registrationProgress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            _progressMessage,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            _buildErrorMessage(),
            const SizedBox(height: 20),
          ],
          _buildInputField(
            "Club Name",
            _clubnameController,
            validator: _validateClubName,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            icon: Icons.sports_soccer,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            "Username",
            _usernameController,
            validator: _validateUsername,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            "Email",
            _emailController,
            validator: _validateEmail,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            icon: Icons.email,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            "Password",
            _passwordController,
            isPassword: true,
            validator: _validatePassword,
            textInputAction: TextInputAction.next,
            icon: Icons.lock,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            "Confirm Password",
            _confirmPasswordController,
            isPassword: true,
            isConfirmPassword: true,
            validator: _validateConfirmPassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleRegistration(),
            icon: Icons.lock_outline,
          ),
          const SizedBox(height: 40),
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
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
    bool isConfirmPassword = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    void Function(String)? onSubmitted,
    IconData? icon,
  }) {
    final fieldKey = hintText.toLowerCase().replaceAll(' ', '');
    final isValid = _fieldValidationState[fieldKey] ?? false;

    return RepaintBoundary(
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        obscureText: isPassword &&
            (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword),
        inputFormatters: _getInputFormatters(fieldKey),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white70),
          enabledBorder: _inputBorder,
          focusedBorder: _inputBorder.copyWith(
            borderSide: BorderSide(
              color: isValid ? Colors.green : Colors.white,
              width: 2,
            ),
          ),
          errorBorder: _errorBorder,
          focusedErrorBorder: _focusedErrorBorder,
          errorStyle: const TextStyle(color: Colors.red),
          prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
          suffixIcon: _buildSuffixIcon(isPassword, isConfirmPassword, isValid),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(
      bool isPassword, bool isConfirmPassword, bool isValid) {
    if (isPassword) {
      return IconButton(
        icon: Icon(
          (isConfirmPassword ? _obscureConfirmPassword : _obscurePassword)
              ? Icons.visibility
              : Icons.visibility_off,
          color: Colors.white70,
        ),
        onPressed: () {
          setState(() {
            if (isConfirmPassword) {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            } else {
              _obscurePassword = !_obscurePassword;
            }
          });
        },
      );
    } else if (isValid) {
      return const Icon(Icons.check_circle, color: Colors.green);
    }
    return null;
  }

  List<TextInputFormatter> _getInputFormatters(String fieldKey) {
    switch (fieldKey) {
      case 'email':
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
          LengthLimitingTextInputFormatter(254),
        ];
      case 'username':
        return [
          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9_]+$')),
          LengthLimitingTextInputFormatter(20),
        ];
      case 'clubname':
        return [
          LengthLimitingTextInputFormatter(30),
        ];
      case 'password':
      case 'confirmpassword':
        return [
          LengthLimitingTextInputFormatter(128),
        ];
      default:
        return [];
    }
  }

  Widget _buildRegisterButton() {
    return RepaintBoundary(
      child: Builder(
        builder: (context) {
          final screenSize = MediaQuery.of(context).size;
          final isFormValid =
              _fieldValidationState.values.every((isValid) => isValid);

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: OptionButton(
              index: 0,
              text: _isLoading ? 'Creating Account...' : 'Sign up',
              onTap: (_isLoading || !isFormValid) ? null : _handleRegistration,
              screenWidth: screenSize.width,
              screenHeight: screenSize.height,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoginLink() {
    return RepaintBoundary(
      child: InkWell(
        onTap: _isLoading ? null : _navigateToLogin,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Already with US? Login here!",
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
  void _validateField(String fieldName) {
    bool isValid = false;

    switch (fieldName) {
      case 'clubname':
        isValid = _validateClubName(_clubnameController.text) == null;
        break;
      case 'username':
        isValid = _validateUsername(_usernameController.text) == null;
        break;
      case 'email':
        isValid = _validateEmail(_emailController.text) == null;
        break;
      case 'password':
        isValid = _validatePassword(_passwordController.text) == null;
        break;
      case 'confirmPassword':
        isValid =
            _validateConfirmPassword(_confirmPasswordController.text) == null;
        break;
    }

    if (_fieldValidationState[fieldName] != isValid) {
      setState(() {
        _fieldValidationState[fieldName] = isValid;
      });
    }
  }

  String? _validateClubName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Club name is required';
    }
    if (value.trim().length < 3) {
      return 'Club name must be at least 3 characters';
    }
    if (value.trim().length > 30) {
      return 'Club name must be less than 30 characters';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Username must be less than 20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

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
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Password must contain uppercase, lowercase, and number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Event handlers with comprehensive error handling
  Future<void> _handleRegistration() async {
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
        _registrationProgress = 0.0;
        _progressMessage = 'Creating account...';
      });

      // Haptic feedback
      HapticFeedback.lightImpact();

      // Extract values
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final username = _usernameController.text.trim();
      final clubName = _clubnameController.text.trim();

      // Step 1: Create user account
      _updateProgress(0.2, 'Creating user account...');
      await AuthServices.signupUser(
          email, password, username, clubName, context);

      if (!mounted) return;

      // Step 2: Get user data
      _updateProgress(0.4, 'Setting up user profile...');
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Failed to get user ID');

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final userData = await ClubFunctions.getUserData(userId);

      if (!mounted) return;

      // Step 3: Initialize club data
      _updateProgress(0.6, 'Initializing club data...');
      if (userData != null) {
        await ClubFunctions.initializeSectorLevels(userRef, userData);
      }

      if (!mounted) return;

      // Step 4: Find or create league
      _updateProgress(0.8, 'Finding league...');
      await _handleLeagueAssignment(userRef);

      if (!mounted) return;

      // Step 5: Complete registration
      _updateProgress(1.0, 'Completing registration...');
      await Future.delayed(const Duration(milliseconds: 500));

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
      await _handleRegistrationError(e);
    }
  }

  Future<void> _handleLeagueAssignment(DocumentReference userRef) async {
    try {
      final availableLeague =
          await LeagueFunctions.findAvailableLeagueWithBot();

      if (availableLeague != null) {
        await _replaceBot(availableLeague, userRef);
      } else {
        await _createNewLeague(userRef);
      }
    } catch (e) {
      debugPrint('Error in league assignment: $e');
      // Create new league as fallback
      await _createNewLeague(userRef);
    }
  }

  Future<void> _replaceBot(
      DocumentSnapshot availableLeague, DocumentReference userRef) async {
    try {
      final leagueData = availableLeague.data() as Map<String, dynamic>;
      final clubs = List<DocumentReference>.from(leagueData['clubs']);

      DocumentReference? botToReplace;
      for (final club in clubs) {
        if (club.id.startsWith('Bot_')) {
          botToReplace = club;
          break;
        }
      }

      if (botToReplace != null) {
        clubs[clubs.indexOf(botToReplace)] = userRef;

        await availableLeague.reference.update({'clubs': clubs});
        await LeagueFunctions.replaceBotInMatches(
            availableLeague, botToReplace.id, userRef.id);
        await userRef.update({'leagueRef': availableLeague.reference});

        debugPrint("Replaced bot ${botToReplace.id} with ${userRef.id}");
      }
    } catch (e) {
      debugPrint('Error replacing bot: $e');
      throw Exception('Failed to join existing league');
    }
  }

  Future<void> _createNewLeague(DocumentReference userRef) async {
    try {
      final newLeagueId = await LeagueFunctions.createNewLeagueWithBots();
      final newLeagueRef =
          FirebaseFirestore.instance.collection('leagues').doc(newLeagueId);

      await userRef.update({'leagueRef': newLeagueRef});
      debugPrint("Created new league: $newLeagueId");
    } catch (e) {
      debugPrint('Error creating new league: $e');
      throw Exception('Failed to create new league');
    }
  }

  void _updateProgress(double progress, String message) {
    if (mounted) {
      setState(() {
        _registrationProgress = progress;
        _progressMessage = message;
      });
    }
  }

  Future<void> _handleRegistrationError(dynamic e) async {
    String errorMessage = 'An unexpected error occurred during registration';

    if (e.toString().contains('network')) {
      errorMessage = 'Network error. Please check your connection.';
    } else if (e.toString().contains('email-already-in-use')) {
      errorMessage = 'This email is already registered.';
    } else if (e.toString().contains('invalid-email')) {
      errorMessage = 'Invalid email format.';
    } else if (e.toString().contains('weak-password')) {
      errorMessage = 'Password is too weak. Please choose a stronger password.';
    } else if (e.toString().contains('too-many-requests')) {
      errorMessage = 'Too many attempts. Please try again later.';
    }

    debugPrint('Registration error: $e');

    if (mounted) {
      setState(() {
        _isLoading = false;
        _registrationProgress = 0.0;
        _progressMessage = '';
        _errorMessage = errorMessage;
      });

      // Haptic feedback for error
      HapticFeedback.mediumImpact();

      // Scroll to top to show error
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToLogin() {
    try {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const TempLoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero),
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
        MaterialPageRoute(builder: (context) => const TempLoginPage()),
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
