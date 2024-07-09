import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/player.dart';
import 'package:pocket_eleven/components/player_details.dart';

class TacticPage extends StatefulWidget {
  const TacticPage({super.key});

  @override
  State<TacticPage> createState() => _TacticPageState();
}

class _TacticPageState extends State<TacticPage> {
  bool _isLoading = true;
  List<Player> footballers = [];
  Map<String, Player?> fieldPositions = {
    'ST1': null,
    'ST2': null,
    'LM': null,
    'RM': null,
    'CM1': null,
    'CM2': null,
    'CM3': null,
    'CAM': null,
    'CDM1': null,
    'CDM2': null,
    'LB': null,
    'CB1': null,
    'CB2': null,
    'CB3': null,
    'RB': null,
    'GK': null,
  };
  String selectedFormation = '4-4-2';
  String? draggedPlayerOriginalPosition;

  final Map<String, List<String>> formations = {
    '4-4-2': [
      'ST1',
      'ST2',
      'LM',
      'CM1',
      'CM2',
      'RM',
      'LB',
      'CB1',
      'CB2',
      'RB',
      'GK'
    ],
    '4-3-3': [
      'ST1',
      'LW',
      'RW',
      'CM1',
      'CM2',
      'CM3',
      'LB',
      'CB1',
      'CB2',
      'RB',
      'GK'
    ],
    '3-5-2': [
      'ST1',
      'ST2',
      'CAM',
      'LM',
      'CDM1',
      'CDM2',
      'RM',
      'CB1',
      'CB2',
      'CB3',
      'GK'
    ],
  };

  final Map<String, String> positionAbbreviations = {
    'LW': 'LW',
    'ST1': 'ST',
    'ST2': 'ST',
    'RW': 'RW',
    'LM': 'LM',
    'RM': 'RM',
    'CM1': 'CM',
    'CM2': 'CM',
    'CM3': 'CM',
    'CAM': 'CAM',
    'CDM1': 'CDM',
    'CDM2': 'CDM',
    'LB': 'LB',
    'CB1': 'CB',
    'CB2': 'CB',
    'CB3': 'CB',
    'RB': 'RB',
    'GK': 'GK',
  };

  final Map<String, Map<String, String>> positionMapping = {
    '4-4-2': {
      'CB3': 'RB',
      'CDM1': 'LB',
      'RW': 'ST2',
      'LW': 'LM',
      'CAM': 'CM1',
      'CDM2': 'CM2',
      'CM3': 'RM',
    },
    '4-3-3': {
      'CB3': 'RB',
      'CDM1': 'LB',
      'ST2': 'RW',
      'LM': 'LW',
      'CAM': 'CM1',
      'CDM2': 'CM2',
      'RM': 'CM3',
    },
    '3-5-2': {
      'RB': 'CB3',
      'LB': 'CDM1',
      'RW': 'ST2',
      'LW': 'LM',
      'CM1': 'CAM',
      'CM2': 'CDM2',
      'CM3': 'RM',
    },
  };

  @override
  void initState() {
    super.initState();
    _generateRandomFootballers();
  }

  Future<void> _generateRandomFootballers() async {
    List<Player> tempList = [];
    for (int i = 0; i < 20; i++) {
      tempList.add(await Player.generateRandomFootballer());
    }

    setState(() {
      footballers = tempList;
      _isLoading = false;
    });
  }

  String _truncateWithEllipsis(String text, int maxLength) {
    return text.length > maxLength
        ? '${text.substring(0, maxLength)}...'
        : text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tactic',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.hoverColor,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              color: AppColors.primaryColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          setState(() {
                            selectedFormation =
                                _previousFormation(selectedFormation);
                            _changeFormation(selectedFormation);
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          selectedFormation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textEnabledColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: () {
                          setState(() {
                            selectedFormation =
                                _nextFormation(selectedFormation);
                            _changeFormation(selectedFormation);
                          });
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: _buildFieldPositions(),
                    ),
                  ),
                  const Divider(
                    color: AppColors.textEnabledColor,
                    height: 1,
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 0.7,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        itemCount: footballers.length,
                        itemBuilder: (context, index) {
                          Player player = footballers[index];
                          return GestureDetector(
                            onTap: () => _showPlayerDetails(player),
                            child: Draggable<Player>(
                              data: player,
                              feedback: _buildPlayerAvatar(player),
                              childWhenDragging: Container(),
                              child: Column(
                                children: [
                                  _buildPlayerAvatar(player),
                                  const SizedBox(height: 4),
                                  Text(
                                    _truncateWithEllipsis(player.name, 6),
                                    style: const TextStyle(
                                      color: AppColors.textEnabledColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    positionAbbreviations[player.position] ??
                                        '',
                                    style: const TextStyle(
                                      color: AppColors.textEnabledColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              onDragStarted: () {
                                setState(() {
                                  draggedPlayerOriginalPosition = fieldPositions
                                      .entries
                                      .firstWhere(
                                          (entry) => entry.value == player,
                                          orElse: () => MapEntry('none', null))
                                      .key;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _previousFormation(String current) {
    List<String> keys = formations.keys.toList();
    int currentIndex = keys.indexOf(current);
    return keys[(currentIndex - 1 + keys.length) % keys.length];
  }

  String _nextFormation(String current) {
    List<String> keys = formations.keys.toList();
    int currentIndex = keys.indexOf(current);
    return keys[(currentIndex + 1) % keys.length];
  }

  void _changeFormation(String newFormation) {
    Map<String, Player?> newFieldPositions = {};
    Map<String, String> mapping = positionMapping[newFormation] ?? {};

    fieldPositions.forEach((key, value) {
      if (value != null) {
        if (mapping.containsKey(key)) {
          newFieldPositions[mapping[key]!] = value;
        } else {
          newFieldPositions[key] = value;
        }
      }
    });

    setState(() {
      fieldPositions = newFieldPositions;
    });
  }

  List<Widget> _buildFieldPositions() {
    switch (selectedFormation) {
      case '4-4-2':
        return _buildFieldPositions442();
      case '4-3-3':
        return _buildFieldPositions433();
      case '3-5-2':
        return _buildFieldPositions352();
      default:
        return _buildFieldPositions442();
    }
  }

  List<Widget> _buildFieldPositions442() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;

    Map<String, Offset> positions = {
      'ST1': Offset(width * 0.5 - 75, height * 0.1),
      'ST2': Offset(width * 0.5 + 15, height * 0.1),
      'LM': Offset(width * 0.1, height * 0.33),
      'CM1': Offset(width * 0.5 - 75, height * 0.37),
      'CM2': Offset(width * 0.5 + 15, height * 0.37),
      'RM': Offset(width * 0.9 - 60, height * 0.33),
      'LB': Offset(width * 0.1, height * 0.6),
      'CB1': Offset(width * 0.5 - 75, height * 0.65),
      'CB2': Offset(width * 0.5 + 15, height * 0.65),
      'RB': Offset(width * 0.9 - 60, height * 0.6),
      'GK': Offset(width * 0.5 - 30, height * 0.9),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldPositions433() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;

    Map<String, Offset> positions = {
      'ST1': Offset(width * 0.5 - 30, height * 0.1),
      'LW': Offset(width * 0.1, height * 0.15),
      'RW': Offset(width * 0.9 - 60, height * 0.15),
      'CM1': Offset(width * 0.3 - 30, height * 0.37),
      'CM2': Offset(width * 0.5 - 30, height * 0.37),
      'CM3': Offset(width * 0.7 - 30, height * 0.37),
      'LB': Offset(width * 0.1, height * 0.6),
      'CB1': Offset(width * 0.5 - 75, height * 0.65),
      'CB2': Offset(width * 0.5 + 15, height * 0.65),
      'RB': Offset(width * 0.9 - 60, height * 0.6),
      'GK': Offset(width * 0.5 - 30, height * 0.9),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldPositions352() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;

    Map<String, Offset> positions = {
      'ST1': Offset(width * 0.5 - 75, height * 0.1),
      'ST2': Offset(width * 0.5 + 15, height * 0.1),
      'CAM': Offset(width * 0.5 - 30, height * 0.33),
      'LM': Offset(width * 0.1, height * 0.35),
      'CDM1': Offset(width * 0.4 - 60, height * 0.38),
      'CDM2': Offset(width * 0.6, height * 0.38),
      'RM': Offset(width * 0.9 - 60, height * 0.35),
      'CB2': Offset(width * 0.5 - 30, height * 0.65),
      'CB1': Offset(width * 0.25 - 30, height * 0.65),
      'CB3': Offset(width * 0.75 - 30, height * 0.65),
      'GK': Offset(width * 0.5 - 30, height * 0.9),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldWidgets(Map<String, Offset> positions) {
    List<Widget> widgets = [];
    positions.forEach((position, offset) {
      String abbreviation = positionAbbreviations[position] ?? '';

      widgets.add(Positioned(
        left: offset.dx,
        top: offset.dy,
        child: GestureDetector(
          onTap: fieldPositions[position] != null
              ? () => _showPlayerDetails(fieldPositions[position]!)
              : null,
          child: DragTarget<Player>(
            builder: (context, candidateData, rejectedData) {
              Player? currentPlayer = fieldPositions[position];
              bool isCorrectPosition = currentPlayer != null &&
                  currentPlayer.position == positionAbbreviations[position];

              return Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: currentPlayer != null
                          ? (isCorrectPosition ? Colors.green : Colors.white)
                          : AppColors.hoverColor,
                      border: Border.all(
                        color: AppColors.textEnabledColor,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Stack(
                      children: [
                        if (currentPlayer == null)
                          Center(
                            child: Text(
                              abbreviation,
                              style: const TextStyle(
                                color: AppColors.textEnabledColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (currentPlayer != null)
                          Positioned.fill(
                            child: Draggable<Player>(
                              data: currentPlayer,
                              feedback: _buildPlayerAvatar(currentPlayer),
                              childWhenDragging: Container(),
                              child: _buildPlayerAvatar(currentPlayer),
                              onDragStarted: () {
                                setState(() {
                                  draggedPlayerOriginalPosition = position;
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (currentPlayer != null)
                    Text(
                      '$abbreviation ${_truncateWithEllipsis(currentPlayer.name, 6)}',
                      style: TextStyle(
                        color: isCorrectPosition
                            ? Colors.green
                            : AppColors.textEnabledColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              );
            },
            onAccept: (data) {
              setState(() {
                // Save the player currently at this position
                Player? currentPlayer = fieldPositions[position];
                // Assign the new player to this position
                fieldPositions[position] = data;
                // If there was a player previously, assign them back to the dragged player's original position
                if (currentPlayer != null &&
                    draggedPlayerOriginalPosition != null) {
                  fieldPositions[draggedPlayerOriginalPosition!] =
                      currentPlayer;
                } else if (draggedPlayerOriginalPosition != null) {
                  // Clear the original position only if it was not occupied
                  fieldPositions[draggedPlayerOriginalPosition!] = null;
                }
                // Remove the new player from the bench
                footballers.remove(data);
              });
            },
          ),
        ),
      ));
    });

    return widgets;
  }

  bool _isCorrectPosition(Player player, String position) {
    return player.position == positionAbbreviations[position];
  }

  Widget _buildPlayerAvatar(Player player) {
    return GestureDetector(
      onTap: () => _showPlayerDetails(player),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage(player.imagePath),
          ),
        ),
      ),
    );
  }

  void _showPlayerDetails(Player player) {
    showDialog(
      context: context,
      builder: (context) {
        return PlayerDetailsDialog(player: player);
      },
    );
  }
}
