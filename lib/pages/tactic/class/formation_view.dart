import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/components/name_formatter.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocket_eleven/pages/tactic/widget/player_selection_dialog.dart';

class FormationView extends StatefulWidget {
  const FormationView({super.key});

  @override
  State<FormationView> createState() => _FormationViewState();
}

class _FormationViewState extends State<FormationView> {
  final Map<String, int> positionMap = {
    'LW1': 1,
    'ST1': 2,
    'ST2': 3,
    'ST3': 4,
    'RW1': 5,
    'LW2': 6,
    'CAM1': 7,
    'CAM2': 8,
    'CAM3': 9,
    'RW2': 10,
    'LM1': 11,
    'CM1': 12,
    'CM2': 13,
    'CM3': 14,
    'RM1': 15,
    'LM2': 16,
    'CDM1': 17,
    'CDM2': 18,
    'CDM3': 19,
    'RM2': 20,
    'LB1': 21,
    'CB1': 22,
    'CB2': 23,
    'CB3': 24,
    'RB2': 25,
    'GK1': 26,
    'GK2': 27,
    'GK3': 28,
    'GK4': 29,
    'GK5': 30,
  };

  Map<String, Player?> selectedPlayers = {
    'LW1': null,
    'ST1': null,
    'ST2': null,
    'ST3': null,
    'RW1': null,
    'LW2': null,
    'CAM1': null,
    'CAM2': null,
    'CAM3': null,
    'RW2': null,
    'LM1': null,
    'CM1': null,
    'CM2': null,
    'CM3': null,
    'RM1': null,
    'LM2': null,
    'CDM1': null,
    'CDM2': null,
    'CDM3': null,
    'RM2': null,
    'LB1': null,
    'CB1': null,
    'CB2': null,
    'CB3': null,
    'RB2': null,
    'GK1': null,
    'GK2': null,
    'GK3': null,
    'GK4': null,
    'GK5': null,
  };

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFormation();
  }

  Future<void> _loadFormation() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String userId = user.uid;
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      QuerySnapshot formationSnapshot = await FirebaseFirestore.instance
          .collection('formations')
          .where('userRef', isEqualTo: userRef)
          .limit(1)
          .get();

      if (formationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot formationDoc = formationSnapshot.docs.first;

        for (String position in positionMap.keys) {
          dynamic playerRef = formationDoc[position];
          if (playerRef != null && playerRef is DocumentReference) {
            DocumentSnapshot playerDoc = await playerRef.get();
            if (playerDoc.exists) {
              selectedPlayers[position] = Player.fromDocument(playerDoc);
            } else {
              selectedPlayers[position] = null;
            }
          } else {
            selectedPlayers[position] = null;
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading formation: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _selectPlayer(String position) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    List<Player> availablePlayers = [];

    try {
      availablePlayers = await FirebaseFirestore.instance
          .collection('players')
          .where('userRef', isEqualTo: userRef)
          .get()
          .then((snapshot) =>
              snapshot.docs.map((doc) => Player.fromDocument(doc)).toList());

      if (selectedPlayers[position] != null) {
        availablePlayers = availablePlayers
            .where((player) =>
                player.playerID != selectedPlayers[position]!.playerID)
            .toList();
      }

      if (!mounted) return;

      final Player? player = await showDialog<Player?>(
        context: context,
        builder: (BuildContext dialogContext) {
          return PlayerSelectionDialog(players: availablePlayers);
        },
      );

      if (player != null && mounted) {
        selectedPlayers.forEach((key, existingPlayer) {
          if (existingPlayer != null &&
              existingPlayer.playerID == player.playerID) {
            selectedPlayers[key] = null;
          }
        });

        setState(() {
          selectedPlayers[position] = player;
        });

        await _saveFormationToFirestore();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting player: $e')),
        );
      }
    }
  }

  Future<void> _saveFormationToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
      }
      return;
    }

    final String userId = user.uid;
    final DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      final formationsCollection =
          FirebaseFirestore.instance.collection('formations');

      QuerySnapshot formationSnapshot = await formationsCollection
          .where('userRef', isEqualTo: userRef)
          .limit(1)
          .get();

      DocumentReference formationRef;

      if (formationSnapshot.docs.isNotEmpty) {
        formationRef = formationSnapshot.docs.first.reference;
      } else {
        formationRef = formationsCollection.doc();
        await formationRef.set({'userRef': userRef});
      }

      final userDoc = await userRef.get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData == null || userData['formationRef'] == null) {
        await userRef.update({
          'formationRef': formationRef,
        });
      }

      Map<String, dynamic> formationData = {
        for (String position in selectedPlayers.keys)
          position: selectedPlayers[position] != null
              ? FirebaseFirestore.instance
                  .collection('players')
                  .doc(selectedPlayers[position]!.playerID)
              : null
      };

      await formationRef.set(formationData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formation saved successfully'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving formation: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? Center(
              child: LoadingAnimationWidget.waveDots(
                color: AppColors.textEnabledColor,
                size: 50,
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.7,
                crossAxisSpacing: 5.0,
                mainAxisSpacing: 5.0,
              ),
              itemCount: positionMap.length,
              itemBuilder: (context, index) {
                final position = positionMap.keys.elementAt(index);
                return GestureDetector(
                  onTap: () => _selectPlayer(position),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      border:
                          Border.all(color: AppColors.borderColor, width: 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: selectedPlayers[position] == null
                          ? Text(
                              position,
                              style: const TextStyle(
                                color: AppColors.textEnabledColor,
                                fontSize: 11,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  selectedPlayers[position]!.imagePath,
                                  width: 40,
                                  height: 40,
                                ),
                                Text(
                                  formatPlayerName(
                                      selectedPlayers[position]!.name),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textEnabledColor,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
