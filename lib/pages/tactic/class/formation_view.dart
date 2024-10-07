import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/tactic/widget/player_cube.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormationView extends StatefulWidget {
  const FormationView({super.key});

  @override
  _FormationViewState createState() => _FormationViewState();
}

class _FormationViewState extends State<FormationView> {
  Player? selectedPlayer;

  Future<void> _selectPlayer(BuildContext context) async {
    final Player? player = await showDialog<Player?>(
      context: context,
      builder: (BuildContext context) {
        return const PlayerSelectionDialog();
      },
    );

    if (player != null) {
      setState(() {
        selectedPlayer = player;
      });

      // Zapis do Firebase
      await _saveFormationToFirestore(context, player);
    }
  }

  Future<void> _saveFormationToFirestore(
      BuildContext context, Player player) async {
    debugPrint(player.playerID);
    if (player.playerID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player ID is missing')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final String userId = user.uid;

    try {
      // Pobieranie referencji klubu z Firebase
      final DocumentReference clubRef =
          await FirebaseFunctions.getClubReference(userId);

      final formationsCollection =
          FirebaseFirestore.instance.collection('formations');
      final formationRef =
          formationsCollection.doc(); // Tworzenie nowego dokumentu

      // Zapis do Firestore z referencjami do klubu i zawodnika
      await formationRef.set({
        'club': clubRef,
        'cube': FirebaseFirestore.instance
            .collection('players')
            .doc(player.playerID),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Formation saved successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      // Informacja o błędzie zapisu do Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving formation: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => _selectPlayer(context),
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        width: screenWidth * 0.2,
        height: screenHeight * 0.2,
        child: Center(
          child: selectedPlayer == null
              ? const Text(
                  'Click to select player',
                  style: TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 16,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(selectedPlayer!.imagePath,
                        width: 50, height: 50),
                    Text(
                      selectedPlayer!.name,
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
                      return PlayerCube(
                        name: player.name,
                        imagePath: player.imagePath,
                        onTap: () {
                          Navigator.of(context).pop(player);
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
