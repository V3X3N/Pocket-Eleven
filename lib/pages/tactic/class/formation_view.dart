import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/components/name_formatter.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_club.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final String userId = user.uid;

    try {
      final String clubRef = await FirebaseFunctions.getClubName(userId);
      QuerySnapshot formationSnapshot = await FirebaseFirestore.instance
          .collection('formations')
          .where('club', isEqualTo: clubRef)
          .limit(1)
          .get();

      if (formationSnapshot.docs.isNotEmpty) {
        DocumentSnapshot formationDoc = formationSnapshot.docs.first;

        for (String position in positionMap.keys) {
          DocumentReference? playerRef = formationDoc[position];
          if (playerRef != null) {
            DocumentSnapshot playerDoc = await playerRef.get();
            if (playerDoc.exists) {
              selectedPlayers[position] = Player.fromDocument(playerDoc);
            }
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading formation: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectPlayer(BuildContext context, String position) async {
    final Player? currentPlayer = selectedPlayers[position];

    if (currentPlayer != null) {
      List<Player> availablePlayers = await ClubFunctions.getPlayersForClub(
          await ClubFunctions.getClubId(
              FirebaseAuth.instance.currentUser!.uid));
      availablePlayers = availablePlayers
          .where((player) => player.playerID != currentPlayer.playerID)
          .toList();

      final Player? player = await showDialog<Player?>(
        context: context,
        builder: (BuildContext context) {
          return PlayerSelectionDialog(players: availablePlayers);
        },
      );

      if (player != null) {
        selectedPlayers.forEach((key, existingPlayer) {
          if (existingPlayer != null &&
              existingPlayer.playerID == player.playerID) {
            selectedPlayers[key] = null;
          }
        });

        setState(() {
          selectedPlayers[position] = player;
        });

        await _saveFormationToFirestore(context);
      }
    } else {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final String userId = user.uid;
      final String clubRef = await FirebaseFunctions.getClubName(userId);
      QuerySnapshot formationSnapshot = await FirebaseFirestore.instance
          .collection('formations')
          .where('club', isEqualTo: clubRef)
          .limit(1)
          .get();

      if (formationSnapshot.docs.isNotEmpty) {
        final currentPlayers =
            formationSnapshot.docs.first.data() as Map<String, dynamic>?;
        final playerCount =
            currentPlayers?.values.where((value) => value != null).length ?? 0;

        if (playerCount >= 12) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cannot select more than 11 players')),
          );
          return;
        }
      }

      List<Player> availablePlayers = await ClubFunctions.getPlayersForClub(
          await ClubFunctions.getClubId(
              FirebaseAuth.instance.currentUser!.uid));

      final Player? player = await showDialog<Player?>(
        context: context,
        builder: (BuildContext context) {
          return PlayerSelectionDialog(players: availablePlayers);
        },
      );

      if (player != null) {
        selectedPlayers.forEach((key, existingPlayer) {
          if (existingPlayer != null &&
              existingPlayer.playerID == player.playerID) {
            selectedPlayers[key] = null;
          }
        });

        setState(() {
          selectedPlayers[position] = player;
        });

        await _saveFormationToFirestore(context);
      }
    }
  }

  Future<void> _saveFormationToFirestore(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final String userId = user.uid;

    try {
      final String clubRef = await FirebaseFunctions.getClubName(userId);
      final formationsCollection =
          FirebaseFirestore.instance.collection('formations');

      QuerySnapshot formationSnapshot = await formationsCollection
          .where('club', isEqualTo: clubRef)
          .limit(1)
          .get();

      DocumentReference formationRef;

      if (formationSnapshot.docs.isNotEmpty) {
        formationRef = formationSnapshot.docs.first.reference;
      } else {
        formationRef = formationsCollection.doc();
        await formationRef.set({'club': clubRef});
      }

      await formationRef.set(
        {
          ...selectedPlayers.map((position, player) {
            return MapEntry(
              position,
              player != null
                  ? FirebaseFirestore.instance
                      .collection('players')
                      .doc(player.playerID)
                  : null,
            );
          }),
        },
        SetOptions(merge: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formation saved successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving formation: $e')),
      );
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
                  onTap: () => _selectPlayer(context, position),
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
