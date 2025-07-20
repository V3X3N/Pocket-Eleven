import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  // Consolidated error message mapping
  static String getErrorMessage(Exception e) {
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
}
