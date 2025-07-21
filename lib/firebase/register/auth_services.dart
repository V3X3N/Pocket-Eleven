import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';
import 'package:pocket_eleven/firebase/register/auth_core.dart';
import 'package:pocket_eleven/firebase/register/cache_manager.dart';
import 'package:pocket_eleven/firebase/register/firebase_error_handling.dart';
import 'package:pocket_eleven/firebase/register/firestore_services.dart';
import 'package:pocket_eleven/firebase/register/register_data.dart';
import 'package:pocket_eleven/firebase/register/register_results.dart';
import 'package:pocket_eleven/firebase/register/login_data.dart';
import 'package:pocket_eleven/firebase/register/login_results.dart';
import 'package:pocket_eleven/firebase/register/ui_helper.dart';

// Unified authentication service for login and registration
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // === REGISTRATION METHODS ===

  Future<RegisterResult> registerUser(
      RegisterData data, BuildContext context) async {
    try {
      final validationError = data.validate();
      if (validationError != null) return RegisterFailure(validationError);

      final trimmedData = data.trimmed;

      if (await FirestoreService.isEmailRegistered(trimmedData.email)) {
        return const RegisterFailure('Email already registered',
            code: 'email-already-in-use');
      }

      final userCredential = await AuthCore.createUser(
        trimmedData.email,
        trimmedData.password,
      );

      final user = userCredential?.user;
      if (user == null) {
        return const RegisterFailure('Failed to create account');
      }

      await Future.wait([
        AuthCore.updateUserProfile(trimmedData.username),
        FirestoreService.saveUserToFirestore(trimmedData, user.uid),
        LeagueFunctions.initializeUserWithLeague(user.uid, trimmedData),
      ]);

      if (context.mounted) {
        UIHelper.showSuccessMessage(context);
      }
      return RegisterSuccess(user.uid);
    } on FirebaseAuthException catch (e) {
      return RegisterFailure(FirebaseErrorHandler.getErrorMessage(e),
          code: e.code);
    } on FirebaseException catch (e) {
      return RegisterFailure(FirebaseErrorHandler.getErrorMessage(e),
          code: e.code);
    } catch (e) {
      debugPrint('Registration error: $e');
      return const RegisterFailure('Registration failed. Please try again.');
    }
  }

  Future<RegisterResult> registerUserSafe(RegisterData data) async {
    try {
      final validationError = data.validate();
      if (validationError != null) return RegisterFailure(validationError);

      final trimmedData = data.trimmed;

      if (await FirestoreService.isEmailRegistered(trimmedData.email)) {
        return const RegisterFailure('Email already registered',
            code: 'email-already-in-use');
      }

      final userCredential = await AuthCore.createUser(
        trimmedData.email,
        trimmedData.password,
      );

      final user = userCredential?.user;
      if (user == null) {
        return const RegisterFailure('Failed to create account');
      }

      await Future.wait([
        AuthCore.updateUserProfile(trimmedData.username),
        FirestoreService.saveUserToFirestore(trimmedData, user.uid),
        LeagueFunctions.initializeUserWithLeague(user.uid, trimmedData),
      ]);

      return RegisterSuccess(user.uid);
    } on FirebaseAuthException catch (e) {
      return RegisterFailure(FirebaseErrorHandler.getErrorMessage(e),
          code: e.code);
    } on FirebaseException catch (e) {
      return RegisterFailure(FirebaseErrorHandler.getErrorMessage(e),
          code: e.code);
    } catch (e) {
      debugPrint('Registration error: $e');
      return const RegisterFailure('Registration failed. Please try again.');
    }
  }

  // === LOGIN METHODS ===

  Future<LoginResult> loginUser(LoginData data, BuildContext context) async {
    try {
      final validationError = data.validate();
      if (validationError != null) return LoginFailure(validationError);

      final trimmedData = data.trimmed;

      final userCredential = await AuthCore.signInUser(
        trimmedData.email,
        trimmedData.password,
      );

      final user = userCredential?.user;
      if (user == null) {
        return const LoginFailure('Failed to sign in');
      }

      await FirestoreService.updateUserData(user.uid, {
        'lastActive': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        UIHelper.showSuccessMessage(context, message: 'Welcome back!');
      }

      return LoginSuccess(user.uid, user);
    } on FirebaseAuthException catch (e) {
      return LoginFailure(FirebaseErrorHandler.getErrorMessage(e),
          code: e.code);
    } on FirebaseException catch (e) {
      return LoginFailure(FirebaseErrorHandler.getErrorMessage(e),
          code: e.code);
    } catch (e) {
      debugPrint('Login error: $e');
      return const LoginFailure('Login failed. Please try again.');
    }
  }

  Future<LoginResult> loginUserSafe(LoginData data) async {
    try {
      final validationError = data.validate();
      if (validationError != null) return LoginFailure(validationError);

      final trimmedData = data.trimmed;

      final userCredential = await AuthCore.signInUser(
        trimmedData.email,
        trimmedData.password,
      );

      final user = userCredential?.user;
      if (user == null) {
        return const LoginFailure('Failed to sign in');
      }

      await FirestoreService.updateUserData(user.uid, {
        'lastActive': FieldValue.serverTimestamp(),
      });

      return LoginSuccess(user.uid, user);
    } on FirebaseAuthException catch (e) {
      return LoginFailure(FirebaseErrorHandler.getErrorMessage(e),
          code: e.code);
    } on FirebaseException catch (e) {
      return LoginFailure(FirebaseErrorHandler.getErrorMessage(e),
          code: e.code);
    } catch (e) {
      debugPrint('Login error: $e');
      return const LoginFailure('Login failed. Please try again.');
    }
  }

  // === SHARED METHODS ===

  Future<bool> sendPasswordReset(String email) async {
    try {
      if (email.trim().isEmpty) return false;

      if (!await isEmailRegistered(email)) return false;

      await AuthCore.sendPasswordResetEmail(email.trim());
      return true;
    } catch (e) {
      debugPrint('Password reset error: $e');
      return false;
    }
  }

  Future<void> signinUser(
      String email, String password, BuildContext context) async {
    if (!context.mounted) return;
    await AuthCore.signInUserWithUI(email, password, context);
  }

  Future<bool> isEmailRegistered(String email) =>
      FirestoreService.isEmailRegistered(email);

  Future<bool> userHasClub(String email) => FirestoreService.userHasClub(email);

  Stream<DocumentSnapshot> getUserDataStream(String userId) =>
      FirestoreService.getUserDataStream(userId);

  Future<Map<String, dynamic>?> getUserData(String userId) =>
      FirestoreService.getUserData(userId);

  Future<void> updateUserData(String userId, Map<String, dynamic> updates) =>
      FirestoreService.updateUserData(userId, updates);

  Future<void> cleanupOnError(String userId) async {
    try {
      await FirestoreService.cleanupUserData(userId);
      await AuthCore.deleteCurrentUser();
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  // === AUTHENTICATION STATE ===

  static bool get isLoggedIn => AuthCore.isLoggedIn;
  static String? get currentUserID => AuthCore.currentUserID;
  static User? get currentUser => AuthCore.currentUser;
  static Stream<User?> get authStateChanges => AuthCore.authStateChanges;
  static Future<void> signOut() => AuthCore.signOut();

  // === CACHE MANAGEMENT ===

  static void clearAllCaches() => CacheManager.clearAllCaches();
}
