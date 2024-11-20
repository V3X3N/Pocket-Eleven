import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';

class FirebaseFunctions {
  static Future<void> saveUser(
    String managerName,
    String email,
    String uid,
    String clubName,
  ) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(uid);

      await userRef.set({
        'email': email,
        'managerName': managerName,
        'clubName': clubName,
        'money': 3000000,
        'trainingLevel': 1,
        'youthLevel': 1,
        'stadiumLevel': 1,
        'scoutingLevel': 1,
      });

      DocumentSnapshot? availableLeague =
          await LeagueFunctions.findAvailableLeagueWithBot();

      if (availableLeague != null) {
        var leagueData = availableLeague.data() as Map<String, dynamic>;
        var clubs = List<String>.from(leagueData['clubs']);

        String? botToReplace;
        for (var club in clubs) {
          if (club.startsWith('Bot_')) {
            botToReplace = club;
            break;
          }
        }

        if (botToReplace != null) {
          clubs[clubs.indexOf(botToReplace)] = clubName;
          await availableLeague.reference.update({
            'clubs': clubs,
          });
          await LeagueFunctions.replaceBotInMatches(
            availableLeague,
            botToReplace,
            clubName,
          );

          await userRef.update({
            'leagueRef': availableLeague.reference,
          });

          debugPrint(
              "Replaced bot: $botToReplace with club: $clubName in league: ${availableLeague.id}");
        } else {
          debugPrint("Bot for replacement not found.");
        }
      } else {
        String newLeagueId = await LeagueFunctions.createNewLeagueWithBots();
        debugPrint("New league created with ID: $newLeagueId");

        DocumentReference newLeagueRef =
            FirebaseFirestore.instance.collection('leagues').doc(newLeagueId);
        await userRef.update({
          'leagueRef': newLeagueRef,
        });
      }
    } catch (error) {
      debugPrint('Error saving user with club data: $error');
    }
  }

  static Future<String> getManagerName(String userId) async {
    try {
      DocumentSnapshot userDoc = await getUserDocument(userId);
      return userDoc.get('managerName') ?? '';
    } catch (error) {
      debugPrint('Error loading manager name: $error');
      return '';
    }
  }

  static Future<String> getClubName(String userId) async {
    try {
      DocumentSnapshot userDoc = await getUserDocument(userId);
      return userDoc.get('clubName') ?? '';
    } catch (error) {
      debugPrint('Error loading club name: $error');
      return '';
    }
  }

  static Future<String> getEmail(String userId) async {
    try {
      DocumentSnapshot userDoc = await getUserDocument(userId);
      return userDoc.get('email') ?? '';
    } catch (error) {
      debugPrint('Error loading email: $error');
      return '';
    }
  }

  static Future<Map<String, dynamic>> getUserData() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return {};

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      throw Exception('User not found');
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> data) async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update(data);
    } else {
      throw Exception('User not found');
    }
  }

  static Future<DocumentSnapshot> getUserDocument(String userId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
    } catch (error) {
      debugPrint('Error fetching user document: $error');
      rethrow;
    }
  }

  static int calculateUpgradeCost(int level) {
    return ((100000 * level) * 2) * 3;
  }

  static Stream<Map<String, dynamic>> getUserDataStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snapshot) => snapshot.data() ?? {});
    } else {
      return const Stream.empty();
    }
  }

  static Future<bool> canAddPlayer(String clubName) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('players')
          .where('clubName', isEqualTo: clubName)
          .get();
      return snapshot.docs.length < 30;
    } catch (error) {
      debugPrint('Error checking player limit: $error');
      return false;
    }
  }
}
