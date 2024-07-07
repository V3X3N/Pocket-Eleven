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
  List<Player?> fieldPositions = List.filled(11, null);
  String selectedFormation = '4-4-2';

  final Map<String, List<String>> formations = {
    '4-4-2': ['ST', 'ST', 'LM', 'CM', 'CM', 'RM', 'LB', 'CB', 'CB', 'RB', 'GK'],
    '4-3-3': ['ST', 'LW', 'RW', 'CM', 'CM', 'CM', 'LB', 'CB', 'CB', 'RB', 'GK'],
    '3-5-2': [
      'ST',
      'ST',
      'CAM',
      'LM',
      'CM',
      'CM',
      'RM',
      'CB',
      'CB',
      'CB',
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
                        icon: Icon(Icons.arrow_left),
                        onPressed: () {
                          setState(() {
                            selectedFormation =
                                _previousFormation(selectedFormation);
                          });
                        },
                      ),
                      Text(
                        selectedFormation,
                        style: const TextStyle(
                          color: AppColors.textEnabledColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_right),
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
                    child: GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 0.8,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: formations[selectedFormation]!.length,
                      itemBuilder: (context, index) {
                        return DragTarget<Player>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              decoration: BoxDecoration(
                                color: fieldPositions[index] != null
                                    ? AppColors.green
                                    : AppColors.hoverColor,
                                border: Border.all(
                                  color: AppColors.textEnabledColor,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  if (fieldPositions[index] == null)
                                    Center(
                                      child: Text(
                                        formations[selectedFormation]![index],
                                        style: const TextStyle(
                                          color: AppColors.textEnabledColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  if (fieldPositions[index] != null)
                                    Positioned.fill(
                                      child: Draggable<Player>(
                                        data: fieldPositions[index],
                                        feedback: _buildPlayerAvatar(
                                            fieldPositions[index]!),
                                        childWhenDragging: Container(),
                                        child: _buildPlayerAvatar(
                                            fieldPositions[index]!),
                                        onDragCompleted: () {
                                          setState(() {
                                            fieldPositions[index] = null;
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
                              fieldPositions[index] = data;
                              footballers.remove(data);
                            });
                          },
                        );
                      },
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
            Text(
              player.name,
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
