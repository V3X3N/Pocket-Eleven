import 'package:flutter/material.dart';
import 'package:pocket_eleven/databases/database_helper.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/league_schedule.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  String clubName = ''; // Variable to store the club name

  @override
  void initState() {
    super.initState();
    _fetchPlayerClubName(); // Fetch player's club name on widget initialization
  }

  Future<void> _fetchPlayerClubName() async {
    // Use the new getPlayerClub function in DatabaseHelper to get the player's club name
    Map<String, dynamic>? playerClub =
        await DatabaseHelper.instance.getPlayerClub();

    if (playerClub != null) {
      clubName = playerClub[DatabaseHelper.columnName];
      setState(() {}); // Update the state to trigger widget rebuild
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.all(20.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: const DecorationImage(
                  image: AssetImage('assets/next_match_banner.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Container on the left
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: const DecorationImage(
                            image: AssetImage('assets/crests/crest_1.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        clubName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),

                  // Container in the middle
                  const SizedBox.shrink(),

                  // Container on the right
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          image: const DecorationImage(
                            image: AssetImage('assets/crests/crest_2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      const Text(
                        'Klub 2',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          // Container for "PLAY" as a MaterialButton with bold text, centered alignment, and orange background color
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            height: 80,
            child: MaterialButton(
              onPressed: () {
                // Handle button press for PLAY
              },
              padding: const EdgeInsets.all(16.0),
              color: AppColors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Center(
                child: Text(
                  'PLAY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16.0),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0),
                  child: MaterialButton(
                    onPressed: () {
                      // Handle button press for Container 1
                    },
                    height: 120,
                    padding: const EdgeInsets.all(16.0),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Container 1',
                        style: TextStyle(
                          color: AppColors.textDisabledColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(right: 20.0, left: 10.0, top: 10.0),
                  child: MaterialButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LeagueSchedulePage()),
                      );
                    },
                    height: 120,
                    padding: const EdgeInsets.all(16.0),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Fixtures',
                        style: TextStyle(
                          color: AppColors.textDisabledColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(left: 20.0, right: 10.0, top: 10.0),
                  child: MaterialButton(
                    onPressed: () {
                      // Handle button press for Container 3
                    },
                    height: 120,
                    padding: const EdgeInsets.all(16.0),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Container 3',
                        style: TextStyle(
                          color: AppColors.textDisabledColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin:
                      const EdgeInsets.only(right: 20.0, left: 10.0, top: 10.0),
                  child: MaterialButton(
                    onPressed: () {
                      // Handle button press for Container 4
                    },
                    height: 120,
                    padding: const EdgeInsets.all(16.0),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Container 4',
                        style: TextStyle(
                          color: AppColors.textDisabledColor,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
