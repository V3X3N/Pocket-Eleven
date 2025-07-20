import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';
import 'package:pocket_eleven/firebase/register/auth_services.dart';
import 'package:pocket_eleven/firebase/register/cache_manager.dart';
import 'package:pocket_eleven/firebase/register/firebase_error_handling.dart';
import 'package:pocket_eleven/firebase/register/firestore_services.dart';
import 'package:pocket_eleven/firebase/register/register_data.dart';
import 'package:pocket_eleven/firebase/register/register_results.dart';
import 'package:pocket_eleven/firebase/register/ui_helper.dart';

// Optimized singleton service with caching and efficient operations
class RegisterService {
  static final RegisterService _instance = RegisterService._internal();
  factory RegisterService() => _instance;
  RegisterService._internal();

  // Main registration method with streamlined error handling
  Future<RegisterResult> registerUser(
      RegisterData data, BuildContext context) async {
    try {
      // Validate input data
      final validationError = data.validate();
      if (validationError != null) return RegisterFailure(validationError);

      final trimmedData = data.trimmed;

      // Check email availability
      if (await FirestoreService.isEmailRegistered(trimmedData.email)) {
        return const RegisterFailure('Email already registered',
            code: 'email-already-in-use');
      }

      // Create user account
      final userCredential = await AuthService.createUser(
        trimmedData.email,
        trimmedData.password,
      );

      final user = userCredential?.user;
      if (user == null) {
        return const RegisterFailure('Failed to create account');
      }

      // Update profile and save to Firestore concurrently
      await Future.wait([
        AuthService.updateUserProfile(trimmedData.username),
        FirestoreService.saveUserToFirestore(trimmedData, user.uid),
        LeagueFunctions.initializeUserWithLeague(user.uid, trimmedData),
      ]);

      // Check if context is still valid before showing UI
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

  // Alternative approach: Return success without showing UI in service
  Future<RegisterResult> registerUserSafe(RegisterData data) async {
    try {
      // Validate input data
      final validationError = data.validate();
      if (validationError != null) return RegisterFailure(validationError);

      final trimmedData = data.trimmed;

      // Check email availability
      if (await FirestoreService.isEmailRegistered(trimmedData.email)) {
        return const RegisterFailure('Email already registered',
            code: 'email-already-in-use');
      }

      // Create user account
      final userCredential = await AuthService.createUser(
        trimmedData.email,
        trimmedData.password,
      );

      final user = userCredential?.user;
      if (user == null) {
        return const RegisterFailure('Failed to create account');
      }

      // Update profile and save to Firestore concurrently
      await Future.wait([
        AuthService.updateUserProfile(trimmedData.username),
        FirestoreService.saveUserToFirestore(trimmedData, user.uid),
        LeagueFunctions.initializeUserWithLeague(user.uid, trimmedData),
      ]);

      // Don't show UI from service - let the calling widget handle it
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

  // Updated signin method with context safety
  Future<void> signinUser(
      String email, String password, BuildContext context) async {
    if (!context.mounted) return;
    await AuthService.signInUser(email, password, context);
  }

  // Delegated methods for better organization (no context needed)
  Future<bool> isEmailRegistered(String email) =>
      FirestoreService.isEmailRegistered(email);

  Future<bool> userHasClub(String email) => FirestoreService.userHasClub(email);

  Stream<DocumentSnapshot> getUserDataStream(String userId) =>
      FirestoreService.getUserDataStream(userId);

  Future<Map<String, dynamic>?> getUserData(String userId) =>
      FirestoreService.getUserData(userId);

  Future<void> updateUserData(String userId, Map<String, dynamic> updates) =>
      FirestoreService.updateUserData(userId, updates);

  // Cleanup operations
  Future<void> cleanupOnError(String userId) async {
    try {
      await FirestoreService.cleanupUserData(userId);
      await AuthService.deleteCurrentUser();
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }

  // Authentication state utilities
  static bool get isLoggedIn => AuthService.isLoggedIn;
  static String? get currentUserID => AuthService.currentUserID;
  static User? get currentUser => AuthService.currentUser;
  static Future<void> signOut() => AuthService.signOut();

  // Cache management
  static void clearAllCaches() => CacheManager.clearAllCaches();
}
