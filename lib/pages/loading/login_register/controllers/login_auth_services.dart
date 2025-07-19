import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Sign in user with email and password
  /// Returns true if successful, throws exception if failed
  Future<bool> signInUser(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw const AuthException('Email and password cannot be empty');
      }

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user != null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Sign in error: $e');
      throw AuthException('An unexpected error occurred during sign in');
    }
  }

  /// Register user with email and password
  /// Returns true if successful, throws exception if failed
  Future<bool> registerUser(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw const AuthException('Email and password cannot be empty');
      }

      if (password.length < 6) {
        throw const AuthException('Password must be at least 6 characters');
      }

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user != null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Registration error: $e');
      throw AuthException('An unexpected error occurred during registration');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Sign out error: $e');
      throw AuthException('Failed to sign out');
    }
  }

  /// Reset password for given email
  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        throw const AuthException('Email cannot be empty');
      }

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Reset password error: $e');
      throw AuthException('Failed to send password reset email');
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final User? user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Delete account error: $e');
      throw AuthException('Failed to delete account');
    }
  }

  /// Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      final User? user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Update email error: $e');
      throw AuthException('Failed to update email');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      final User? user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      if (newPassword.length < 6) {
        throw const AuthException('Password must be at least 6 characters');
      }

      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Update password error: $e');
      throw AuthException('Failed to update password');
    }
  }

  /// Re-authenticate user (required for sensitive operations)
  Future<void> reauthenticateUser(String password) async {
    try {
      final User? user = currentUser;
      if (user == null) {
        throw const AuthException('No user is currently signed in');
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      debugPrint('Re-authentication error: $e');
      throw AuthException('Failed to re-authenticate user');
    }
  }

  /// Get user-friendly error messages
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'provider-already-linked':
        return 'Account is already linked to this provider.';
      case 'credential-already-in-use':
        return 'This credential is already associated with a different user account.';
      default:
        return 'An authentication error occurred. Please try again.';
    }
  }
}

/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Authentication state enum for better state management
enum AuthState {
  authenticated,
  unauthenticated,
  loading,
}

/// Authentication result with additional information
class AuthResult {
  final bool success;
  final String? errorMessage;
  final User? user;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });

  factory AuthResult.success(User user) => AuthResult(
        success: true,
        user: user,
      );

  factory AuthResult.failure(String message) => AuthResult(
        success: false,
        errorMessage: message,
      );
}
