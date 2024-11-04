import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/models/player.dart';

class PlayerFunctions {
  static Future<void> savePlayerToFirestore(
      BuildContext context, Player player) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      const snackBar = SnackBar(content: Text('User not logged in'));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

    final playersCollection = FirebaseFirestore.instance.collection('players');
    final newPlayerRef = playersCollection.doc();
    final playerId = newPlayerRef.id;
    final clubName = await FirebaseFunctions.getClubName(user.uid);

    await newPlayerRef.set({
      'id': playerId,
      'name': player.name,
      'position': player.position,
      'ovr': player.ovr,
      'age': player.age,
      'nationality': player.nationality,
      'imagePath': player.imagePath,
      'flagPath': player.flagPath,
      'value': player.value,
      'salary': player.salary,
      'param1': player.param1,
      'param2': player.param2,
      'param3': player.param3,
      'param4': player.param4,
      'param1Name': player.param1Name,
      'param2Name': player.param2Name,
      'param3Name': player.param3Name,
      'param4Name': player.param4Name,
      'matchesPlayed': player.matchesPlayed,
      'goals': player.goals,
      'assists': player.assists,
      'yellowCards': player.yellowCards,
      'redCards': player.redCards,
      'isYouth': player.isYouth,
      'club': clubName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    const successSnackBar = SnackBar(
      content: Text('Player added to your club successfully'),
      duration: Duration(seconds: 1),
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
    }
  }

  static Future<void> updatePlayerData(
      String playerID, Map<String, dynamic> playerData) async {
    try {
      final DocumentReference playerDoc =
          FirebaseFirestore.instance.collection('players').doc(playerID);
      await playerDoc.update(playerData);
    } catch (e) {
      debugPrint('Error updating player data: $e');
    }
  }
}
