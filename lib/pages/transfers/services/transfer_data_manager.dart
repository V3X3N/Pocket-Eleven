import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pocket_eleven/models/player.dart';

/// A data manager service for handling transfer-related Firebase operations.
///
/// Features:
/// - Defensive programming with null checks and error handling
/// - Efficient batch operations for better performance
/// - Automatic data refresh based on timestamps
/// - Parallel processing for improved speed
/// - Comprehensive error handling and logging
class TransfersDataManager {
  static const int _transferRefreshMinutes = 4;
  static const int _maxPlayers = 20;
  static const Duration _dataConsistencyDelay = Duration(milliseconds: 500);

  final FirebaseFirestore _firestore;
  final User? _currentUser;

  /// Creates a transfers data manager.
  ///
  /// [firestore] - FirebaseFirestore instance (default: FirebaseFirestore.instance)
  /// [currentUser] - Current authenticated user (default: FirebaseAuth.instance.currentUser)
  TransfersDataManager({
    FirebaseFirestore? firestore,
    User? currentUser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _currentUser = currentUser ?? FirebaseAuth.instance.currentUser;

  /// Checks if the current user is authenticated
  bool get isUserAuthenticated => _currentUser != null;

  /// Gets the transfers document reference for the current user
  DocumentReference? get _transfersRef => isUserAuthenticated
      ? _firestore.collection('transfers').doc(_currentUser!.uid)
      : null;

  /// Gets the temporary transfers collection reference
  CollectionReference get _tempTransfersRef =>
      _firestore.collection('temp_transfers');

  /// Initializes transfer data by checking expiration and refreshing if needed.
  ///
  /// Returns a list of players from the transfer market.
  /// Throws [Exception] if user is not authenticated or operation fails.
  Future<List<Player>> initializeTransferData() async {
    if (!isUserAuthenticated) {
      throw Exception('User authentication required');
    }

    try {
      await _checkAndRefreshData();
      return await _fetchPlayersFromTransfers();
    } catch (e) {
      debugPrint('Error initializing transfer data: $e');
      rethrow;
    }
  }

  /// Checks if transfer data exists and is still valid, refreshes if expired.
  Future<void> _checkAndRefreshData() async {
    final transfersRef = _transfersRef;
    if (transfersRef == null) return;

    try {
      final transferDoc = await transfersRef.get();

      if (!transferDoc.exists) {
        debugPrint('No transfer data found, generating new data');
        await _generateAndSavePlayers();
        return;
      }

      final data = transferDoc.data() as Map<String, dynamic>?;
      if (data == null) {
        await _generateAndSavePlayers();
        return;
      }

      final createdAt = data['createdAt'] as Timestamp?;
      final deleteAt = data['deleteAt'] as Timestamp?;

      if (createdAt == null || deleteAt == null) {
        // Wait for background process to complete
        await Future.delayed(const Duration(seconds: 2));
        return _checkAndRefreshData();
      }

      if (DateTime.now().isAfter(deleteAt.toDate())) {
        debugPrint('Transfer data expired, refreshing');
        await _refreshData();
      } else {
        debugPrint('Using existing valid transfer data');
      }
    } catch (e) {
      debugPrint('Error checking transfer data: $e');
      rethrow;
    }
  }

  /// Refreshes transfer data by cleaning up old data and generating new players.
  Future<void> _refreshData() async {
    final transfersRef = _transfersRef;
    if (transfersRef == null) return;

    try {
      final transferDoc = await transfersRef.get();

      if (transferDoc.exists) {
        final data = transferDoc.data() as Map<String, dynamic>?;
        final playerRefs = data?['playerRefs'] as List<dynamic>? ?? [];

        if (playerRefs.isNotEmpty) {
          // Clean up old players in batch for performance
          final batch = _firestore.batch();
          for (final ref in playerRefs) {
            if (ref is DocumentReference) {
              batch.delete(ref);
            }
          }
          await batch.commit();
        }

        await transfersRef.delete();
        debugPrint('Cleaned up old transfer data');
      }

      await _generateAndSavePlayers();
    } catch (e) {
      debugPrint('Error refreshing transfer data: $e');
      rethrow;
    }
  }

  /// Generates new random players and saves them to Firestore.
  Future<void> _generateAndSavePlayers() async {
    final transfersRef = _transfersRef;
    if (transfersRef == null) return;

    try {
      final currentTime = DateTime.now();
      final List<DocumentReference> playerRefs = [];

      // Generate players in parallel for better performance
      final playerFutures = List.generate(
        _maxPlayers,
        (_) => Player.generateRandomFootballer(),
      );

      final players = await Future.wait(playerFutures);

      // Save players in batch operation for efficiency
      final batch = _firestore.batch();
      for (final player in players) {
        final playerDocRef = _tempTransfersRef.doc();
        batch.set(playerDocRef, player.toDocument());
        playerRefs.add(playerDocRef);
      }
      await batch.commit();

      // Save transfer metadata
      await transfersRef.set({
        'playerRefs': playerRefs,
        'createdAt': Timestamp.fromDate(currentTime),
        'deleteAt': Timestamp.fromDate(
          currentTime.add(const Duration(minutes: _transferRefreshMinutes)),
        ),
      });

      debugPrint('Generated ${players.length} new transfer players');

      // Small delay to ensure data consistency
      await Future.delayed(_dataConsistencyDelay);
    } catch (e) {
      debugPrint('Error generating players: $e');
      rethrow;
    }
  }

  /// Fetches players from the transfers collection.
  ///
  /// Returns a list of Player objects.
  /// Returns empty list if no transfer data exists.
  Future<List<Player>> _fetchPlayersFromTransfers() async {
    final transfersRef = _transfersRef;
    if (transfersRef == null) return [];

    try {
      final transferDoc = await transfersRef.get();

      if (!transferDoc.exists) {
        return [];
      }

      final data = transferDoc.data() as Map<String, dynamic>?;
      final playerRefs = data?['playerRefs'] as List<dynamic>? ?? [];

      if (playerRefs.isEmpty) {
        return [];
      }

      // Fetch all player documents in parallel for better performance
      final playerFutures =
          playerRefs.cast<DocumentReference>().map((ref) => ref.get()).toList();

      final playerDocs = await Future.wait(playerFutures);

      final players = playerDocs
          .where((doc) => doc.exists && doc.data() != null)
          .map((doc) => Player.fromDocument(doc))
          .toList();

      debugPrint('Fetched ${players.length} transfer players');
      return players;
    } catch (e) {
      debugPrint('Error fetching players: $e');
      rethrow;
    }
  }

  /// Forces a refresh of transfer data.
  ///
  /// Useful for manual refresh operations triggered by user interaction.
  Future<List<Player>> forceRefresh() async {
    if (!isUserAuthenticated) {
      throw Exception('User authentication required');
    }

    try {
      await _refreshData();
      return await _fetchPlayersFromTransfers();
    } catch (e) {
      debugPrint('Error during force refresh: $e');
      rethrow;
    }
  }
}
