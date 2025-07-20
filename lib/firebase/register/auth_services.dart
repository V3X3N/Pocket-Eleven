import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/register/firebase_error_handling.dart';
import 'package:pocket_eleven/firebase/register/ui_helper.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication state utilities
  static bool get isLoggedIn => _auth.currentUser != null;
  static String? get currentUserID => _auth.currentUser?.uid;
  static User? get currentUser => _auth.currentUser;
  static Future<void> signOut() => _auth.signOut();

  // Create user account
  static Future<UserCredential?> createUser(
      String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Update user profile
  static Future<void> updateUserProfile(String username) async {
    await _auth.currentUser?.updateDisplayName(username);
  }

  // Streamlined sign-in method
  static Future<void> signInUser(
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

  // Delete current user (for cleanup)
  static Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }
}
