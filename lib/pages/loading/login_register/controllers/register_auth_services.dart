import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';

// Immutable data class with built-in validation
@immutable
class RegisterData {
  final String email;
  final String password;
  final String username;
  final String clubName;

  const RegisterData({
    required this.email,
    required this.password,
    required this.username,
    required this.clubName,
  });

  String? validate() {
    final trimmed = this.trimmed;

    // Required field checks
    if (trimmed.email.isEmpty) return 'Email is required';
    if (trimmed.username.isEmpty) return 'Username is required';
    if (trimmed.clubName.isEmpty) return 'Club name is required';
    if (password.isEmpty) return 'Password is required';

    // Length validations
    if (trimmed.username.length < 3 || trimmed.username.length > 20) {
      return 'Username must be 3-20 characters';
    }
    if (trimmed.clubName.length < 3 || trimmed.clubName.length > 30) {
      return 'Club name must be 3-30 characters';
    }
    if (password.length < 8) return 'Password must be at least 8 characters';

    // Format validations
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(trimmed.email)) {
      return 'Invalid email format';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed.username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  RegisterData get trimmed => RegisterData(
        email: email.trim(),
        password: password,
        username: username.trim(),
        clubName: clubName.trim(),
      );
}

// Sealed result classes for type-safe error handling
@immutable
sealed class RegisterResult {
  const RegisterResult();
}

class RegisterSuccess extends RegisterResult {
  final String userId;
  const RegisterSuccess(this.userId);
}

class RegisterFailure extends RegisterResult {
  final String error;
  final String? code;
  const RegisterFailure(this.error, {this.code});
}

// Optimized singleton service with caching and efficient operations
class RegisterService {
  static final RegisterService _instance = RegisterService._internal();
  factory RegisterService() => _instance;
  RegisterService._internal();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Simple cache with automatic cleanup
  static final Map<String, bool> _emailCache = {};
  static DateTime _lastCacheClean = DateTime.now();

  // Main registration method with streamlined error handling
  Future<RegisterResult> registerUser(
      RegisterData data, BuildContext context) async {
    try {
      // Validate input data
      final validationError = data.validate();
      if (validationError != null) return RegisterFailure(validationError);

      final trimmedData = data.trimmed;

      // Check email availability
      if (await isEmailRegistered(trimmedData.email)) {
        return const RegisterFailure('Email already registered',
            code: 'email-already-in-use');
      }

      // Create user account
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: trimmedData.email,
        password: trimmedData.password,
      );

      final user = userCredential.user;
      if (user == null)
        return const RegisterFailure('Failed to create account');

      // Update profile and save to Firestore concurrently
      await Future.wait([
        user.updateDisplayName(trimmedData.username),
        _saveUserToFirestore(trimmedData, user.uid),
        LeagueFunctions.initializeUserWithLeague(user.uid, trimmedData),
      ]);

      _showSuccessMessage(context);
      return RegisterSuccess(user.uid);
    } on FirebaseAuthException catch (e) {
      return RegisterFailure(_getErrorMessage(e), code: e.code);
    } on FirebaseException catch (e) {
      return RegisterFailure(_getErrorMessage(e), code: e.code);
    } catch (e) {
      debugPrint('Registration error: $e');
      return const RegisterFailure('Registration failed. Please try again.');
    }
  }

  // Optimized Firestore operations
  static Future<void> _saveUserToFirestore(
      RegisterData data, String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'username': data.username,
      'email': data.email,
      'clubName': data.clubName,
      'uid': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // Cached email existence check
  Future<bool> isEmailRegistered(String email) async {
    _cleanCacheIfNeeded();

    if (_emailCache.containsKey(email)) return _emailCache[email]!;

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      final exists = snapshot.docs.isNotEmpty;
      _emailCache[email] = exists;
      return exists;
    } catch (e) {
      debugPrint('Email check error: $e');
      return false;
    }
  }

  // Optimized user operations
  Future<bool> userHasClub(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      final data = snapshot.docs.first.data();
      return data['clubName']?.toString().isNotEmpty ?? false;
    } catch (e) {
      debugPrint('Club check error: $e');
      return false;
    }
  }

  // Streamlined sign-in method
  Future<void> signinUser(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _showSuccessMessage(context, message: 'Successfully signed in');
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(context, _getErrorMessage(e));
    } catch (e) {
      _showErrorMessage(context, 'Sign in failed. Please try again.');
    }
  }

  // Authentication state utilities
  static bool get isLoggedIn => _auth.currentUser != null;
  static String? get currentUserID => _auth.currentUser?.uid;
  static User? get currentUser => _auth.currentUser;
  static Future<void> signOut() => _auth.signOut();

  // Efficient user data operations
  Stream<DocumentSnapshot> getUserDataStream(String userId) =>
      _firestore.collection('users').doc(userId).snapshots();

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('Get user data error: $e');
      return null;
    }
  }

  Future<void> updateUserData(
      String userId, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      debugPrint('Update user data error: $e');
    }
  }

  // Cleanup operations
  Future<void> cleanupOnError(String userId) async {
    try {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('users').doc(userId));
      batch.delete(_firestore.collection('matches').doc(userId));
      await batch.commit();
      await _auth.currentUser?.delete();
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  // Helper methods
  static void _cleanCacheIfNeeded() {
    if (DateTime.now().difference(_lastCacheClean).inMinutes > 5) {
      _emailCache.clear();
      _lastCacheClean = DateTime.now();
    }
  }

  static void _showSuccessMessage(BuildContext context,
      {String message = 'Registration successful'}) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Consolidated error message mapping
  static String _getErrorMessage(Exception e) {
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'email-already-in-use' => 'Email already registered',
        'invalid-email' => 'Invalid email address',
        'weak-password' => 'Password is too weak',
        'user-not-found' => 'No account found with this email',
        'wrong-password' => 'Incorrect password',
        'user-disabled' => 'Account has been disabled',
        'too-many-requests' => 'Too many attempts. Try again later',
        'network-request-failed' => 'Network error. Check connection',
        _ => 'Authentication failed. Please try again',
      };
    }

    if (e is FirebaseException) {
      return switch (e.code) {
        'unavailable' => 'Service temporarily unavailable',
        'deadline-exceeded' => 'Request timeout. Please try again',
        'permission-denied' => 'Permission denied',
        'resource-exhausted' => 'Service quota exceeded',
        _ => 'Service error. Please try again',
      };
    }

    return 'An unexpected error occurred';
  }

  // Cache management
  static void clearAllCaches() {
    _emailCache.clear();
  }
}
