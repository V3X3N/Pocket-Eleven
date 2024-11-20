import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      await newPlayerRef.set({
        ...player.toDocument(),
        'userRef': userRef,
        'id': playerId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await userRef.update({
        'playerRefs': FieldValue.arrayUnion([newPlayerRef]),
      });

      const successSnackBar = SnackBar(
        content: Text('Player added to your club successfully'),
        duration: Duration(seconds: 1),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
      }
    } catch (e) {
      debugPrint('Error saving player to Firestore: $e');
      const errorSnackBar = SnackBar(
        content: Text('Failed to add player'),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
      }
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
