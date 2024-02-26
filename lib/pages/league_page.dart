import 'package:flutter/material.dart';
import 'package:pocket_eleven/databases/database_helper.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'players_page.dart';

class LeaguePage extends StatefulWidget {
  const LeaguePage({super.key});

  @override
  State<LeaguePage> createState() => _LeaguePageState();
}

class _LeaguePageState extends State<LeaguePage> {
  late Future<List<Map<String, dynamic>>> clubs;

  @override
  void initState() {
    super.initState();
    clubs = DatabaseHelper.instance.getClubs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: clubs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<Map<String, dynamic>> clubList = snapshot.data!;

            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/league_bg.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 70,
                      flexibleSpace: Container(
                        color: AppColors.hoverColor,
                        child: const Center(
                          child: Text(
                            'L E A G U E   1',
                            style: TextStyle(
                              color: AppColors.textEnabledColor,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        children: clubList.map((club) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayersPage(
                                    clubId: club[DatabaseHelper.columnId] ?? -1,
                                  ),
                                ),
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
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            club[DatabaseHelper.columnName] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              color: AppColors.textEnabledColor,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                'MP: ${club[DatabaseHelper.columnMatchesPlayed] ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColors.textEnabledColor,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'W: ${club[DatabaseHelper.columnMatchesWon] ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColors.textEnabledColor,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'D: ${club[DatabaseHelper.columnMatchesDrawn] ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColors.textEnabledColor,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'L: ${club[DatabaseHelper.columnMatchesLost] ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColors.textEnabledColor,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'GF: ${club[DatabaseHelper.columnGoalsFor] ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColors.textEnabledColor,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'GA: ${club[DatabaseHelper.columnGoalsAgainst] ?? 0}',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: AppColors.textEnabledColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.blue, // Ustawienie koloru na niebieski
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
