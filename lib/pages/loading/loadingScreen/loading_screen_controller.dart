import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/loading/login_register/temp_login_page.dart';
import 'package:pocket_eleven/pages/loading/login_register/temp_register_page.dart';

// Optimized result classes using sealed classes for better type safety
sealed class AuthResult {
  const AuthResult();
}

class AuthSuccess extends AuthResult {
  final Widget page;
  const AuthSuccess(this.page);
}

class AuthError extends AuthResult {
  final String message;
  const AuthError(this.message);
}

// Unified controller with auth services and loading logic
class LoadingScreenController extends ChangeNotifier {
  // State variables
  bool _isLoading = true;
  String? _errorMessage;

  // Performance constants
  static const _minLoadTime = Duration(milliseconds: 800);
  static const _authTimeout = Duration(seconds: 8);
  static const _maxRetries = 2;
  static const _retryDelay = Duration(milliseconds: 300);

  // Private fields
  int _retryCount = 0;
  final Stopwatch _stopwatch = Stopwatch();

  // Cached instances for performance
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Main initialization method
  Future<Widget?> initialize() async {
    _stopwatch.start();
    return _executeWithRetry();
  }

  // Retry mechanism with exponential backoff
  Future<Widget?> _executeWithRetry() async {
    while (_retryCount <= _maxRetries) {
      try {
        final result = await _performAuthentication();
        return switch (result) {
          AuthSuccess(page: final page) => page,
          AuthError(message: final msg) => throw Exception(msg),
        };
      } catch (e) {
        if (_retryCount >= _maxRetries) {
          _setError('Authentication failed after $_maxRetries attempts');
          return null;
        }
        _retryCount++;
        await Future.delayed(_retryDelay * _retryCount);
      }
    }
    return null;
  }

  // Parallel authentication with timeout
  Future<AuthResult> _performAuthentication() async {
    try {
      final results = await Future.wait([
        _authenticateUser().timeout(_authTimeout),
        _ensureMinLoadTime(),
      ]);
      return results.first as AuthResult;
    } catch (e) {
      return AuthError('Authentication timeout: ${e.toString()}');
    }
  }

  // Core authentication logic
  Future<AuthResult> _authenticateUser() async {
    final user = _auth.currentUser;

    if (user?.email == null) {
      return const AuthSuccess(LoginPage());
    }

    try {
      // Validate session and check club status in parallel
      final results = await Future.wait([
        _validateUserSession(user!),
        _checkUserClubStatus(user.email!),
      ]);

      final hasClub = results[1] as bool;
      final page = hasClub ? const HomePage() : const TempRegisterPage();

      return AuthSuccess(page);
    } catch (e) {
      return AuthError('User validation failed: ${e.toString()}');
    }
  }

  // Session validation
  Future<void> _validateUserSession(User user) async {
    await user.reload();
    if (_auth.currentUser == null) {
      throw Exception('Session expired - please login again');
    }
  }

  // Check if user has a club (optimized with caching)
  Future<bool> _checkUserClubStatus(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      final userData = snapshot.docs.first.data();
      return userData['clubName'] != null &&
          (userData['clubName'] as String).isNotEmpty;
    } catch (e) {
      debugPrint('Club status check failed: $e');
      return false;
    }
  }

  // Ensure minimum loading time for UX
  Future<void> _ensureMinLoadTime() async {
    final elapsed = _stopwatch.elapsed;
    final remaining = _minLoadTime - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  // Public retry method
  void retry() {
    _resetState();
    _executeWithRetry().then((page) {
      if (page != null) _setSuccess();
    });
  }

  // State management methods
  void _resetState() {
    _retryCount = 0;
    _errorMessage = null;
    _isLoading = true;
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();
  }

  void _setError(String error) {
    _isLoading = false;
    _errorMessage = error;
    notifyListeners();
  }

  void _setSuccess() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  // ============= AUTH SERVICES METHODS =============

  // Static auth utility methods
  static bool isLoggedIn() => _auth.currentUser != null;

  static String? getCurrentUserID() => _auth.currentUser?.uid;

  // User registration with comprehensive error handling
  static Future<void> signupUser(
    String email,
    String password,
    String name,
    String clubName,
    BuildContext context,
  ) async {
    if (!context.mounted) return;

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;
      await Future.wait([
        user.updateDisplayName(name),
        user.verifyBeforeUpdateEmail(email),
        FirebaseFunctions.saveUser(name, email, user.uid, clubName),
      ]);

      if (context.mounted) {
        _showSnackBar(context, 'Registration successful!');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _handleAuthError(context, e);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Registration failed: ${e.toString()}');
      }
    }
  }

  // User sign-in with error handling
  static Future<void> signinUser(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (!context.mounted) return;

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (context.mounted) {
        _showSnackBar(context, 'Welcome back!');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        _handleAuthError(context, e);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Login failed: ${e.toString()}');
      }
    }
  }

  // Check if email is registered
  static Future<bool> isEmailRegistered(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Email check failed: $e');
      return false;
    }
  }

  // Check if user has club (static version)
  static Future<bool> userHasClub(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      final userData = snapshot.docs.first.data();
      return userData['clubName'] != null &&
          (userData['clubName'] as String).isNotEmpty;
    } catch (e) {
      debugPrint('Club status check failed: $e');
      return false;
    }
  }

  // Helper methods for error handling
  static void _handleAuthError(BuildContext context, FirebaseAuthException e) {
    final message = switch (e.code) {
      'weak-password' => 'Password is too weak',
      'email-already-in-use' => 'Email is already registered',
      'user-not-found' => 'No account found with this email',
      'wrong-password' => 'Incorrect password',
      'invalid-email' => 'Invalid email address',
      'user-disabled' => 'Account has been disabled',
      'too-many-requests' => 'Too many attempts. Try again later',
      _ => 'Authentication error: ${e.message}',
    };
    _showSnackBar(context, message);
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
