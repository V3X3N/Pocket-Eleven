import 'package:flutter/material.dart';
import 'package:pocket_eleven/databases/database_helper.dart';
import 'package:pocket_eleven/design/colors.dart';

class LeagueSchedulePage extends StatefulWidget {
  const LeagueSchedulePage({super.key});

  @override
  _LeagueSchedulePageState createState() => _LeagueSchedulePageState();
}

class _LeagueSchedulePageState extends State<LeagueSchedulePage> {
  List<String> allClubs = [];
  List<List<String>> allMatchFixtures = [];

  @override
  void initState() {
    super.initState();
    _fetchAllClubsAndGenerateFixtures();
  }

  void _fetchAllClubsAndGenerateFixtures() async {
    List<Map<String, dynamic>> clubs = await DatabaseHelper.instance.getClubs();

    for (int i = 0; i < clubs.length; i++) {
      allClubs.add(clubs[i][DatabaseHelper.columnName]);
    }

    // Generate fixtures for all matchdays
    _generateAllMatchFixtures();

    // Call setState to trigger a rebuild
    setState(() {});
  }

  void _generateAllMatchFixtures() {
    int numberOfClubs = allClubs.length;

    // Creating two lists for home and away teams to manage which teams play home and away alternately
    List<String> homeTeams = [];
    List<String> awayTeams = [];

    // Adding half of the teams to home teams and the other half to away teams
    for (int i = 0; i < numberOfClubs; i++) {
      if (i % 2 == 0) {
        homeTeams.add(allClubs[i]);
      } else {
        awayTeams.add(allClubs[i]);
      }
    }

    // Looping through matchdays
    for (int matchday = 1; matchday <= 19; matchday++) {
      List<String> matchFixtures = [];

      // Looping through each matchday's matches
      for (int i = 0; i < homeTeams.length; i++) {
        String homeClub = homeTeams[i];
        String awayClub = awayTeams[i];

        // Adjusting alternating sides for each matchday
        if (matchday % 2 == 0) {
          // Even matchday, swap sides
          String temp = homeClub;
          homeClub = awayClub;
          awayClub = temp;
        }

        String fixture = '$homeClub vs $awayClub';
        matchFixtures.add(fixture);
      }

      // Rotating teams for the next matchday
      String lastHomeTeam = homeTeams.removeLast();
      String firstAwayTeam = awayTeams.removeAt(0);
      homeTeams.insert(1, firstAwayTeam);
      awayTeams.add(lastHomeTeam);

      // Adding the fixtures to the list for each matchday
      allMatchFixtures.add(matchFixtures);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        title: const Text(
          'League Schedule',
          style: TextStyle(color: AppColors.textEnabledColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textEnabledColor),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Matchday Fixtures:',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
              const SizedBox(height: 15.0),
              Expanded(
                child: ListView.builder(
                  itemCount: allMatchFixtures.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Matchday ${index + 1}:',
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.textEnabledColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: 10, // Constant number of matches per matchday
                          itemBuilder: (context, matchIndex) {
                            String fixture = allMatchFixtures[index][matchIndex];
                            return SizedBox(
                              height: 50.0, // Constant height for each match row
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 35,
                                    height: 35,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        fixture.split(' vs ')[0],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 25,
                                    height: 25,
                                    color: Colors.white,
                                    child: const Center(
                                      child: Text(
                                        'VS',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        fixture.split(' vs ')[1],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 35,
                                    height: 35,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
