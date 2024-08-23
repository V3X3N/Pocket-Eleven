import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/components/player_details.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayersView extends StatefulWidget {
  const PlayersView({super.key});

  @override
  _PlayersViewState createState() => _PlayersViewState();
}

class _PlayersViewState extends State<PlayersView> {
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: screenWidth,
      height: screenHeight,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : players.isEmpty
              ? const Center(
                  child: Text(
                    'No players found',
                    style: TextStyle(
                      color: AppColors.textEnabledColor,
                      fontSize: 18,
                    ),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PlayerDetailsDialog(player: player);
                          },
                        );
                      },
                      child: Container(
                        color: Colors.green,
                      ),
                    );
                  },
                ),
    );
  }
}
