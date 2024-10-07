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
  List<Player?> selectedPlayers =
      List.generate(30, (_) => null); // Lista z 30 elementami null
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

        // Wczytanie referencji do zawodników
        for (int i = 0; i < 30; i++) {
          DocumentReference? playerRef = formationDoc['players'][i];
          if (playerRef != null) {
            DocumentSnapshot playerDoc = await playerRef.get();
            if (playerDoc.exists) {
              selectedPlayers[i] = Player.fromDocument(playerDoc);
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

  Future<void> _selectPlayer(BuildContext context, int index) async {
    final Player? player = await showDialog<Player?>(
      context: context,
      builder: (BuildContext context) {
        return const PlayerSelectionDialog();
      },
    );

    if (player != null) {
      setState(() {
        selectedPlayers[index] = player;
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

      // Sprawdzamy, czy istnieje dokument formacji
      QuerySnapshot formationSnapshot = await formationsCollection
          .where('club', isEqualTo: clubRef)
          .limit(1)
          .get();

      DocumentReference formationRef;

      if (formationSnapshot.docs.isNotEmpty) {
        // Jeśli dokument istnieje, aktualizujemy go
        formationRef = formationSnapshot.docs.first.reference;
      } else {
        // Jeśli nie istnieje, tworzymy nowy dokument
        formationRef = formationsCollection.doc();
        await formationRef.set({
          'club': clubRef,
        });
      }

      // Zaktualizuj lub ustaw referencje do zawodników
      await formationRef.set(
          {
            'players': selectedPlayers.map((player) {
              return player != null
                  ? FirebaseFirestore.instance
                      .collection('players')
                      .doc(player.playerID)
                  : null;
            }).toList(),
          },
          SetOptions(
              merge:
                  true)); // Użycie merge, aby zaktualizować istniejący dokument

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
                crossAxisCount: 5, // 5 kolumn
                childAspectRatio: 1.0,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: 30, // 30 kwadratów
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _selectPlayer(context, index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.hoverColor,
                      border:
                          Border.all(color: AppColors.borderColor, width: 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: selectedPlayers[index] == null
                          ? const Text(
                              'Select Player',
                              style: TextStyle(
                                color: AppColors.textEnabledColor,
                                fontSize: 16,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(selectedPlayers[index]!.imagePath,
                                    width: 50, height: 50),
                                Text(
                                  selectedPlayers[index]!.name,
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
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      return GestureDetector(
                        onTap: () => Navigator.of(context).pop(player),
                        child: Column(
                          children: [
                            Image.asset(player.imagePath,
                                width: 50, height: 50),
                            Text(player.name),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
