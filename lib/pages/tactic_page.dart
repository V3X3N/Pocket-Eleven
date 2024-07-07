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
    'CM1': null,
    'CM2': null,
    'RM': null,
    'LB': null,
    'CB1': null,
    'CB2': null,
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
      'CM1',
      'CM2',
      'RM',
      'CB1',
      'CB2',
      'CB3',
      'GK'
    ],
    // Add more formations as needed
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
    List<Widget> widgets = [];
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;

    Map<String, Offset> positions = {
      'ST1': Offset(width * 0.5 - 30, height * 0.1),
      'ST2': Offset(width * 0.5 + 30, height * 0.1),
      'LM': Offset(width * 0.1, height * 0.3),
      'CM1': Offset(width * 0.3, height * 0.3),
      'CM2': Offset(width * 0.7, height * 0.3),
      'RM': Offset(width * 0.9, height * 0.3),
      'LB': Offset(width * 0.1, height * 0.5),
      'CB1': Offset(width * 0.3, height * 0.5),
      'CB2': Offset(width * 0.7, height * 0.5),
      'RB': Offset(width * 0.9, height * 0.5),
      'GK': Offset(width * 0.5, height * 0.7),
    };

    List<String>? currentFormation = formations[selectedFormation];

    if (currentFormation != null) {
      for (var position in currentFormation) {
        Offset? pos = positions[position];
        if (pos != null) {
          widgets.add(
            Positioned(
              left: pos.dx,
              top: pos.dy,
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
                              position,
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
                              feedback:
                                  _buildPlayerAvatar(fieldPositions[position]!),
                              childWhenDragging: Container(),
                              child:
                                  _buildPlayerAvatar(fieldPositions[position]!),
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
