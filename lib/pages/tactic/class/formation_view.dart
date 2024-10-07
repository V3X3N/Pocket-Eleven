import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormationView extends StatefulWidget {
  const FormationView({super.key});

  @override
  _FormationViewState createState() => _FormationViewState();
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
      final DocumentReference clubRef =
          await FirebaseFunctions.getClubReference(userId);
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
    final Player? player = await showDialog<Player?>(
      context: context,
      builder: (BuildContext context) {
        return const PlayerSelectionDialog();
      },
    );

    if (player != null) {
      setState(() {
        selectedPlayers[position] = player;
      });

      await _saveFormationToFirestore(context);
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
      final DocumentReference clubRef =
          await FirebaseFunctions.getClubReference(userId);
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
        await formationRef.set({
          'club': clubRef,
        });
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
                    : null);
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 1.0,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: positionMap.length,
              itemBuilder: (context, index) {
                final position = positionMap.keys.elementAt(index);
                return GestureDetector(
                  onTap: () => _selectPlayer(context, position),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.hoverColor,
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
                                fontSize: 16,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                    selectedPlayers[position]!.imagePath,
                                    width: 50,
                                    height: 50),
                                Text(
                                  selectedPlayers[position]!.name,
                                  style: const TextStyle(
                                    color: AppColors.textEnabledColor,
                                    fontSize: 14,
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

class PlayerSelectionDialog extends StatefulWidget {
  const PlayerSelectionDialog({super.key});

  @override
  _PlayerSelectionDialogState createState() => _PlayerSelectionDialogState();
}

class _PlayerSelectionDialogState extends State<PlayerSelectionDialog> {
  List<Player> players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String clubId = await FirebaseFunctions.getClubId(user.uid);
      if (clubId.isNotEmpty) {
        final List<Player> loadedPlayers =
            await FirebaseFunctions.getPlayersForClub(clubId);
        setState(() {
          players = loadedPlayers;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select a Player'),
      content: isLoading
          ? const CircularProgressIndicator()
          : players.isEmpty
              ? const Text('No players found')
              : SizedBox(
                  width: double.maxFinite,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(players[index]);
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                players[index].imagePath,
                                height: 80,
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                players[index].name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
