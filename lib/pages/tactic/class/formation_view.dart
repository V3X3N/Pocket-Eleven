import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/components/player_details.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/pages/tactic/widget/player_cube.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class FormationView extends StatefulWidget {
  const FormationView({super.key});

  @override
  State<FormationView> createState() => _FormationViewState();
}

class _FormationViewState extends State<FormationView> {
  bool isLoading = true;
  List<String> players = List.generate(11, (index) => "Player ${index + 1}");
  String selectedFormation = '4-4-2';
  List<Player> availablePlayers = [];

  @override
  void initState() {
    super.initState();
    loadFormation();
    _loadPlayers();
  }

  Future<void> loadFormation() async {
    var data = await getFormationFromFirestore('formation_1');
    if (data != null) {
      setState(() {
        players = List<String>.from(data['players']);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveFormation() async {
    await saveFormationToFirestore('formation_1', players);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formation saved successfully!')),
    );
  }

  Future<void> _loadPlayers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String clubId = await FirebaseFunctions.getClubId(user.uid);
      if (clubId.isNotEmpty) {
        final List<Player> loadedPlayers =
            await FirebaseFunctions.getPlayersForClub(clubId);
        setState(() {
          availablePlayers = loadedPlayers;
        });
      }
    }
  }

  void _selectPlayerForPosition(int positionIndex) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a player'),
          content: availablePlayers.isEmpty
              ? const Text('No players available')
              : SizedBox(
                  width: 300,
                  height: 400,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: availablePlayers.length,
                    itemBuilder: (context, index) {
                      final player = availablePlayers[index];
                      return PlayerCube(
                        name: player.name,
                        imagePath: player.imagePath,
                        onTap: () {
                          setState(() {
                            players[positionIndex] = player.name;
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
        );
      },
    );
  }

  void _showPlayerStatistics(String playerName) {
    final selectedPlayer =
        availablePlayers.firstWhere((player) => player.name == playerName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlayerDetailsDialog(player: selectedPlayer);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Container(
        margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        width: double.infinity,
        height: double.infinity,
        child: isLoading
            ? Center(
                child: LoadingAnimationWidget.waveDots(
                  color: AppColors.textEnabledColor,
                  size: 50,
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _changeFormation('4-4-2'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedFormation == '4-4-2'
                                      ? AppColors.primaryColor
                                      : AppColors.blueColor,
                                ),
                                child: const Text('4-4-2'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () => _changeFormation('4-3-3'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: selectedFormation == '4-3-3'
                                      ? AppColors.primaryColor
                                      : AppColors.blueColor,
                                ),
                                child: const Text('4-3-3'),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.save),
                            color: AppColors.textEnabledColor,
                            onPressed: saveFormation,
                            tooltip: 'Save Formation',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Stack(
                          children: _buildFormation(
                              constraints.maxHeight, constraints.maxWidth),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  List<Widget> _buildFormation(double maxHeight, double maxWidth) {
    if (selectedFormation == '4-4-2') {
      return [
        _buildPlayerPosition(0, maxHeight * 0.05, maxWidth * 0.4),
        _buildPlayerPosition(1, maxHeight * 0.2, maxWidth * 0.1),
        _buildPlayerPosition(2, maxHeight * 0.2, maxWidth * 0.3),
        _buildPlayerPosition(3, maxHeight * 0.2, maxWidth * 0.5),
        _buildPlayerPosition(4, maxHeight * 0.2, maxWidth * 0.7),
        _buildPlayerPosition(5, maxHeight * 0.4, maxWidth * 0.1),
        _buildPlayerPosition(6, maxHeight * 0.4, maxWidth * 0.3),
        _buildPlayerPosition(7, maxHeight * 0.4, maxWidth * 0.5),
        _buildPlayerPosition(8, maxHeight * 0.4, maxWidth * 0.7),
        _buildPlayerPosition(9, maxHeight * 0.6, maxWidth * 0.35),
        _buildPlayerPosition(10, maxHeight * 0.6, maxWidth * 0.55),
      ];
    } else if (selectedFormation == '4-3-3') {
      return [
        _buildPlayerPosition(0, maxHeight * 0.05, maxWidth * 0.4),
        _buildPlayerPosition(1, maxHeight * 0.2, maxWidth * 0.1),
        _buildPlayerPosition(2, maxHeight * 0.2, maxWidth * 0.3),
        _buildPlayerPosition(3, maxHeight * 0.2, maxWidth * 0.5),
        _buildPlayerPosition(4, maxHeight * 0.2, maxWidth * 0.7),
        _buildPlayerPosition(5, maxHeight * 0.4, maxWidth * 0.2),
        _buildPlayerPosition(6, maxHeight * 0.4, maxWidth * 0.4),
        _buildPlayerPosition(7, maxHeight * 0.4, maxWidth * 0.6),
        _buildPlayerPosition(8, maxHeight * 0.6, maxWidth * 0.2),
        _buildPlayerPosition(9, maxHeight * 0.6, maxWidth * 0.4),
        _buildPlayerPosition(10, maxHeight * 0.6, maxWidth * 0.6),
      ];
    }
    return [];
  }

  Widget _buildPlayerPosition(int playerIndex, double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () {
          _selectPlayerForPosition(playerIndex);
        },
        onLongPress: () {
          _showPlayerStatistics(players[playerIndex]);
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.blueColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderColor, width: 2),
          ),
          child: Center(
            child: Text(
              players[playerIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changeFormation(String newFormation) async {
    setState(() {
      selectedFormation = newFormation;
      isLoading = true;
    });

    var data = await getFormationFromFirestore('formation_$newFormation');
    if (data != null) {
      setState(() {
        players = List<String>.from(data['players']);
        isLoading = false;
      });
    } else {
      setState(() {
        players = List.generate(11, (index) => "Player ${index + 1}");
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> getFormationFromFirestore(
      String formationId) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'formationId': formationId,
      'players': players,
    };
  }

  Future<void> saveFormationToFirestore(
      String formationId, List<String> players) async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
