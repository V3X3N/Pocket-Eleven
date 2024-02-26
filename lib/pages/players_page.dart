import 'package:flutter/material.dart';
import 'package:pocket_eleven/databases/database_helper.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/components/player_details_dialog.dart';

class PlayersPage extends StatefulWidget {
  final int clubId;

  const PlayersPage({super.key, required this.clubId});

  @override
  // ignore: library_private_types_in_public_api
  _PlayersPageState createState() => _PlayersPageState();
}

class _PlayersPageState extends State<PlayersPage> {
  late Future<List<Map<String, dynamic>>> players;
  late String clubName;

  @override
  void initState() {
    super.initState();
    players = DatabaseHelper.instance.getPlayersByClubId(widget.clubId);
    getClubName();
  }

  void getClubName() async {
    Map<String, dynamic>? club = await DatabaseHelper.instance.getClubById(widget.clubId);
    setState(() {
      clubName = club?[DatabaseHelper.columnName] ?? 'Club Name';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: players,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Map<String, dynamic>> playerList = snapshot.data!;

            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/locker_room_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 70,
                      iconTheme: const IconThemeData(color: AppColors.textDisabledColor),
                      flexibleSpace: Container(
                        color: AppColors.hoverColor,
                        child: Center(
                          child: Text(
                            clubName,
                            style: const TextStyle(
                              color: AppColors.textEnabledColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      centerTitle: true,
                      backgroundColor: Colors.transparent,
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        color: Colors.transparent,
                        child: Column(
                          children: playerList.map((player) {
                            return GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PlayerDetailsDialog(player: player);
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  margin: const EdgeInsets.all(10.0),
                                  width: MediaQuery.of(context).size.width - 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.hoverColor,
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${player[DatabaseHelper.columnFirstName]} ${player[DatabaseHelper.columnLastName]}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: AppColors.textEnabledColor,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Position: ${player[DatabaseHelper.columnPosition]}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: AppColors.textEnabledColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
