import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/components/player_details.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransfersPlayerWidget extends StatelessWidget {
  final Player player;

  const TransfersPlayerWidget({
    super.key,
    required this.player,
  });

  Future<void> _savePlayerToFirestore(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final String userId = user.uid;
    final DocumentReference clubRef =
        await FirebaseFunctions.getClubReference(userId);

    final playersCollection = FirebaseFirestore.instance.collection('players');

    await playersCollection.add({
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
      'club': clubRef,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Player added to your club successfully')),
    );
  }

  Future<void> _confirmPlayerSelection(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final String userId = user.uid;
    final DocumentReference clubRef =
        await FirebaseFunctions.getClubReference(userId);

    final bool canAdd = await FirebaseFunctions.canAddPlayer(clubRef.id);

    if (!canAdd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add player: club limit reached')),
      );
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Selection'),
          content: Text('Are you sure you want to select ${player.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _savePlayerToFirestore(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return PlayerDetailsDialog(player: player);
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: AppColors.blueColor,
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              player.name,
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      player.position,
                      style: const TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'OVR: ${player.ovr}',
                      style: const TextStyle(
                        color: AppColors.textEnabledColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Image.asset(
                      player.flagPath,
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                IconButton(
                  icon:
                      const Icon(Icons.check_box_rounded, color: Colors.green),
                  onPressed: () => _confirmPlayerSelection(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
