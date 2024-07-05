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
  List<Player?> fieldPositions = List.filled(25, null);

  final List<String> fieldPositionLabels = [
    'LW',
    'ST',
    'ST',
    'ST',
    'RW',
    'LW',
    'CAM',
    'CAM',
    'CAM',
    'RW',
    'LM',
    'CM',
    'CM',
    'CM',
    'RM',
    'LM',
    'CDM',
    'CDM',
    'CDM',
    'RM',
    'LB',
    'CB',
    'GK', // Poprawiona pozycja bramkarza
    'CB',
    'RB',
  ];

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
                      itemCount: fieldPositions.length,
                      itemBuilder: (context, index) {
                        return DragTarget<Player>(
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              decoration: BoxDecoration(
                                color: fieldPositions[index] != null
                                    ? Colors
                                        .green // Zmiana koloru na zielony, gdy jest zawodnik
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
                                        fieldPositionLabels[index],
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

  Widget _buildPlayerAvatar(Player player) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          player.imagePath,
          width: 60, // Zwiększono szerokość avatara
          height: 60, // Zwiększono wysokość avatara
        ),
        const SizedBox(height: 8), // Zwiększono odstęp
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              player.position,
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontWeight: FontWeight.bold, // Pogrubienie tekstu
                fontSize: 14, // Zwiększono rozmiar tekstu
              ),
            ),
            const SizedBox(width: 4), // Odstęp między pozycją a imieniem
            Text(
              player.name,
              style: const TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 14, // Zwiększono rozmiar tekstu
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ],
    );
  }
}
