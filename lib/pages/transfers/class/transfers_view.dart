import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_widget.dart';

class TransfersView extends StatefulWidget {
  const TransfersView({super.key});

  @override
  State<TransfersView> createState() => _TransfersViewState();
}

class _TransfersViewState extends State<TransfersView> {
  List<Player> _players = [];

  @override
  void initState() {
    super.initState();
    _generatePlayers();
  }

  Future<void> _generatePlayers() async {
    List<Player> players = [];
    for (int i = 0; i < 10; i++) {
      Player player = await Player.generateRandomFootballer();
      players.add(player);
    }
    setState(() {
      _players = players;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: _players.length,
        itemBuilder: (context, index) {
          return TransfersPlayerWidget(
              // TODO: Implement transfers data to firestore
              player: _players[index]);
        },
      ),
    );
  }
}
