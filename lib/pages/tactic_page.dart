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
  late Image _leagueImage;
  List<Player> selectedFootballers = [];
  List<Player?> fieldPositions = List.filled(25, null);
  List<Player?> benchPlayers = List.filled(14, null);

  @override
  void initState() {
    super.initState();
    _loadLeagueImage();
    _generateRandomFootballers();
  }

  void _loadLeagueImage() {
    _leagueImage = Image.asset('assets/background/league_bg.png');

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _generateRandomFootballers() async {
    List<Player> tempList = [];
    for (int i = 0; i < 25; i++) {
      tempList.add(await Player.generateRandomFootballer());
    }

    setState(() {
      selectedFootballers = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'L E A G U E   1',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.hoverColor,
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _leagueImage.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 1,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: fieldPositions.length,
                          itemBuilder: (context, index) {
                            return DragTarget<Player>(
                              builder: (context, candidateData, rejectedData) {
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.textEnabledColor,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: fieldPositions[index] != null
                                      ? Draggable<Player>(
                                          data: fieldPositions[index],
                                          feedback: _buildPlayerAvatar(
                                              fieldPositions[index]!),
                                          childWhenDragging: Container(),
                                          child: _buildPlayerAvatar(
                                              fieldPositions[index]!),
                                        )
                                      : Container(),
                                );
                              },
                              onAccept: (data) {
                                setState(() {
                                  fieldPositions[index] = data;
                                  selectedFootballers.remove(data);
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
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            childAspectRatio: 1,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                          ),
                          itemCount: selectedFootballers.length,
                          itemBuilder: (context, index) {
                            Player player = selectedFootballers[index];
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
        ],
      ),
    );
  }

  Widget _buildPlayerAvatar(Player player) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          player.imagePath,
          width: 50,
          height: 50,
        ),
        const SizedBox(height: 4),
        Text(
          player.name,
          style: const TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          player.position,
          style: const TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
