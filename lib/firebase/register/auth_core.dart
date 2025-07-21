import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/register/firebase_error_handling.dart';
import 'package:pocket_eleven/firebase/register/ui_helper.dart';

// Core Firebase Authentication operations
class AuthCore {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication state utilities
  static bool get isLoggedIn => _auth.currentUser != null;
  static String? get currentUserID => _auth.currentUser?.uid;
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  static Future<void> signOut() => _auth.signOut();

  // Create user account
  static Future<UserCredential?> createUser(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign in user
  static Future<UserCredential?> signInUser(
      String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Legacy sign-in with UI handling
  static Future<void> signInUserWithUI(
      String email, String password, BuildContext context) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      if (context.mounted) {
        UIHelper.showSuccessMessage(context, message: 'Successfully signed in');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        UIHelper.showErrorMessage(
            context, FirebaseErrorHandler.getErrorMessage(e));
      }
    } catch (e) {
      if (context.mounted) {
        UIHelper.showErrorMessage(context, 'Sign in failed. Please try again.');
      }
    }
  }

  // Update user profile
  static Future<void> updateUserProfile(String username) async {
    await _auth.currentUser?.updateDisplayName(username);
  }

  // Send password reset email
  static Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Delete current user
  static Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }

  // Email verification
  static Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // Reload current user data
  static Future<void> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
  }
}
