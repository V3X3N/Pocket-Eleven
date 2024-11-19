import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_players.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/components/player_details.dart';
import 'package:pocket_eleven/pages/club/class/youth_view.dart';

class YouthPlayerConfirmWidget extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final void Function(Player) onPlayerSelected;

  const YouthPlayerConfirmWidget({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onPlayerSelected,
  });

  Future<void> _confirmYouthSelection(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final String userId = user.uid;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.hoverColor,
                border: Border.all(color: AppColors.borderColor, width: 1),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Confirm Youth Selection',
                      style: TextStyle(
                          color: AppColors.textEnabledColor, fontSize: 18),
                    ),
                  ),
                  Text(
                    'Are you sure you want to select ${player.name}?\n'
                    'Cost: \$${player.value}',
                    style: const TextStyle(
                        color: AppColors.textEnabledColor, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: const Text('Confirm',
                            style:
                                TextStyle(color: AppColors.textEnabledColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User document not found')),
      );
      return;
    }

    final double userMoney = userDoc.data()?['money']?.toDouble() ?? 0.0;

    if (userMoney >= player.value) {
      final updatedMoney = userMoney - player.value;

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'money': updatedMoney,
      });

      debugPrint('Youth player value: \$${player.value}');

      await PlayerFunctions.savePlayerToFirestore(context, player);

      await _removePlayerFromFirestore(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Youth player ${player.name} added to your club!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Not enough money to add ${player.name}.'),
        ),
      );
    }
  }

  Future<void> _removePlayerFromFirestore(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final transfersRef = firestore.collection('youth').doc(user.uid);
    final tempTransfersRef =
        firestore.collection('temp_youth').doc(player.playerID);

    await transfersRef.update({
      'playerRefs': FieldValue.arrayRemove([tempTransfersRef])
    });

    await tempTransfersRef.delete();

    if (context.mounted) {
      YouthViewState? transfersState =
          context.findAncestorStateOfType<YouthViewState>();
      transfersState?.removePlayerFromList(player);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return PlayerDetailsDialog(player: player);
            },
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[300] : AppColors.blueColor,
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
                if (!isSelected)
                  IconButton(
                    icon: const Icon(Icons.check_box_rounded,
                        color: Colors.green),
                    onPressed: () => _confirmYouthSelection(context),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
