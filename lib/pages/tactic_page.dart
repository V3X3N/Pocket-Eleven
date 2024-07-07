import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/player.dart';

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
    // Add more formations as needed
  };

  final Map<String, String> positionAbbreviations = {
    'ST1': 'ST',
    'ST2': 'ST',
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
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: footballers.length,
                      itemBuilder: (context, index) {
                        Player player = footballers[index];
                        return Draggable<Player>(
                          data: player,
                          feedback: _buildPlayerAvatar(player),
                          childWhenDragging: Container(),
                          child: _buildPlayerAvatar(player),
                        );
                      },
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

  List<Widget> _buildFieldPositions() {
    switch (selectedFormation) {
      case '4-4-2':
        return _buildFieldPositions442();
      case '4-3-3':
        return _buildFieldPositions433();
      case '3-5-2':
        return _buildFieldPositions352();
      default:
        return [];
    }
  }

  List<Widget> _buildFieldPositions442() {
    List<Widget> widgets = [];
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
    List<Widget> widgets = [];
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;

    Map<String, Offset> positions = {
      'ST1': Offset(width * 0.5 - 30, height * 0.1),
      'LW': Offset(width * 0.15, height * 0.13),
      'RW': Offset(width * 0.85 - 60, height * 0.13),
      'CM1': Offset(width * 0.5 - 30, height * 0.37),
      'CM2': Offset(width * 0.2, height * 0.37),
      'CM3': Offset(width * 0.8 - 60, height * 0.37),
      'LB': Offset(width * 0.1, height * 0.6),
      'CB1': Offset(width * 0.5 - 75, height * 0.65),
      'CB2': Offset(width * 0.5 + 15, height * 0.65),
      'RB': Offset(width * 0.9 - 60, height * 0.6),
      'GK': Offset(width * 0.5 - 30, height * 0.9),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldPositions352() {
    List<Widget> widgets = [];
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
      'CB1': Offset(width * 0.5 - 30, height * 0.65),
      'CB2': Offset(width * 0.25 - 30, height * 0.65),
      'CB3': Offset(width * 0.75 - 30, height * 0.65),
      'GK': Offset(width * 0.5 - 30, height * 0.9),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldWidgets(Map<String, Offset> positions) {
    List<Widget> widgets = [];
    List<String>? currentFormation = formations[selectedFormation];

    if (currentFormation != null) {
      for (var position in currentFormation) {
        Offset? pos = positions[position];
        if (pos != null) {
          String abbreviation = positionAbbreviations[position] ?? position;
          widgets.add(
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: SizedBox(
                width: 60, // Set a fixed width
                height: 60, // Set a fixed height
                child: DragTarget<Player>(
                  builder: (context, candidateData, rejectedData) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: fieldPositions[position] != null
                            ? AppColors.green
                            : AppColors.hoverColor,
                        border: Border.all(
                          color: AppColors.textEnabledColor,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          if (fieldPositions[position] == null)
                            Center(
                              child: Text(
                                abbreviation,
                                style: const TextStyle(
                                  color: AppColors.textEnabledColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (fieldPositions[position] != null)
                            Positioned.fill(
                              child: Draggable<Player>(
                                data: fieldPositions[position],
                                feedback: _buildPlayerAvatar(
                                    fieldPositions[position]!),
                                childWhenDragging: Container(),
                                child: _buildPlayerAvatar(
                                    fieldPositions[position]!),
                                onDragCompleted: () {
                                  setState(() {
                                    fieldPositions[position] = null;
                                  });
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  onAccept: (data) {
                    setState(() {
                      fieldPositions[position] = data;
                      footballers.remove(data);
                    });
                  },
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  Widget _buildPlayerAvatar(Player player) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          player.imagePath,
          width: 60,
          height: 60,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              player.position,
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                player.name,
                style: const TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
