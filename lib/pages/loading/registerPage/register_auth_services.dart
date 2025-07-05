import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/firebase/firebase_club.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';

// Immutable data class with validation
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

  // Validation with comprehensive checks
  String? validate() {
    final emailTrimmed = email.trim();
    final usernameTrimmed = username.trim();
    final clubNameTrimmed = clubName.trim();

    if (emailTrimmed.isEmpty) return 'Email is required';
    if (usernameTrimmed.isEmpty) return 'Username is required';
    if (clubNameTrimmed.isEmpty) return 'Club name is required';
    if (password.isEmpty) return 'Password is required';

    // Enhanced validation
    if (usernameTrimmed.length < 3 || usernameTrimmed.length > 20) {
      return 'Username must be 3-20 characters';
    }
    if (clubNameTrimmed.length < 3 || clubNameTrimmed.length > 30) {
      return 'Club name must be 3-30 characters';
    }
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(emailTrimmed)) {
      return 'Invalid email format';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(usernameTrimmed)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  // Factory for trimmed data
  RegisterData get trimmed => RegisterData(
        email: email.trim(),
        password: password,
        username: username.trim(),
        clubName: clubName.trim(),
      );
}

// Sealed result class for better error handling
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

// Optimized service with better error handling and performance
class RegisterService {
  static final RegisterService _instance = RegisterService._internal();
  factory RegisterService() => _instance;
  RegisterService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Main registration with comprehensive error handling
  Future<RegisterResult> registerUser(
      RegisterData data, BuildContext context) async {
    try {
      // Validate data first
      final validationError = data.validate();
      if (validationError != null) {
        return RegisterFailure(validationError);
      }

      final trimmedData = data.trimmed;

      // Create user account
      final authResult = await _createUserAccount(trimmedData, context);
      if (authResult is RegisterFailure) return authResult;

      final userId = (authResult as RegisterSuccess).userId;
      final userRef = _firestore.collection('users').doc(userId);

      // Batch operations for better performance
      final batch = _firestore.batch();

      // Initialize user data
      await _initializeUserData(userRef, userId, batch);

      // Handle league assignment
      await _handleLeagueAssignment(userRef, batch);

      // Commit batch
      await batch.commit();

      return RegisterSuccess(userId);
    } on FirebaseAuthException catch (e) {
      return RegisterFailure(_getAuthErrorMessage(e), code: e.code);
    } on FirebaseException catch (e) {
      return RegisterFailure(_getFirestoreErrorMessage(e), code: e.code);
    } catch (e) {
      debugPrint('RegisterService Error: $e');
      return RegisterFailure('An unexpected error occurred. Please try again.');
    }
  }

  // Optimized account creation
  Future<RegisterResult> _createUserAccount(
      RegisterData data, BuildContext context) async {
    try {
      await AuthServices.signupUser(
        data.email,
        data.password,
        data.username,
        data.clubName,
        context,
      );

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        return const RegisterFailure('Failed to get user ID after signup');
      }

      return RegisterSuccess(userId);
    } catch (e) {
      rethrow;
    }
  }

  // Optimized initialization with batch operations
  Future<void> _initializeUserData(
    DocumentReference userRef,
    String userId,
    WriteBatch batch,
  ) async {
    try {
      final userData = await ClubFunctions.getUserData(userId);
      if (userData == null) {
        throw Exception('Failed to retrieve user data after creation');
      }

      // Use batch for better performance
      await ClubFunctions.initializeSectorLevels(userRef, userData);
    } catch (e) {
      throw Exception('Failed to initialize user data: $e');
    }
  }

  // Optimized league assignment
  Future<void> _handleLeagueAssignment(
      DocumentReference userRef, WriteBatch batch) async {
    try {
      final availableLeague =
          await LeagueFunctions.findAvailableLeagueWithBot();

      if (availableLeague != null) {
        await _replaceUserInExistingLeague(availableLeague, userRef, batch);
      } else {
        await _createNewLeagueForUser(userRef, batch);
      }
    } catch (e) {
      throw Exception('Failed to assign league: $e');
    }
  }

  // Optimized league replacement
  Future<void> _replaceUserInExistingLeague(
    DocumentSnapshot availableLeague,
    DocumentReference userRef,
    WriteBatch batch,
  ) async {
    final leagueData = availableLeague.data() as Map<String, dynamic>?;
    if (leagueData == null) throw Exception('League data is null');

    final clubs = List<DocumentReference>.from(leagueData['clubs'] ?? []);
    final botIndex = clubs.indexWhere((club) => club.id.startsWith('Bot_'));

    if (botIndex == -1) throw Exception('No bot found to replace');

    final botRef = clubs[botIndex];
    clubs[botIndex] = userRef;

    // Use batch operations
    batch.update(availableLeague.reference, {'clubs': clubs});
    batch.update(userRef, {'leagueRef': availableLeague.reference});

    // Handle match replacement separately (can't be batched)
    await LeagueFunctions.replaceBotInMatches(
      availableLeague,
      botRef.id,
      userRef.id,
    );
  }

  // Optimized league creation
  Future<void> _createNewLeagueForUser(
      DocumentReference userRef, WriteBatch batch) async {
    final newLeagueId = await LeagueFunctions.createNewLeagueWithBots();
    if (newLeagueId.isEmpty) throw Exception('Failed to create new league');

    final newLeagueRef = _firestore.collection('leagues').doc(newLeagueId);
    batch.update(userRef, {'leagueRef': newLeagueRef});
  }

  // User-friendly error messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again later.';
      case 'deadline-exceeded':
        return 'Request timeout. Please try again.';
      default:
        return 'Database error. Please try again.';
    }
  }

  // Cleanup method for error recovery
  Future<void> cleanupOnError(String userId) async {
    try {
      await Future.wait([
        _firestore.collection('users').doc(userId).delete(),
        _auth.currentUser?.delete() ?? Future.value(),
      ]);
    } catch (e) {
      debugPrint('Error during cleanup: $e');
    }
  }
}
