import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 1,
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
                  image: AssetImage('assets/background/next_match_banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
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
                      const Text(
                        // TODO: Display proper Players Club name
                        "ClubName",
                        style: TextStyle(
                            color: AppColors.textEnabledColor, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox.shrink(),
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
                        style: TextStyle(
                            color: AppColors.textEnabledColor, fontSize: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            height: 80,
            child: MaterialButton(
              onPressed: () {
                // TODO: Handle button press for PLAY
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
                    color: AppColors.textEnabledColor,
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
                      // TODO: Handle button press for Container 1
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
                      // TODO: Handle button press for Container 1
                    },
                    height: 120,
                    padding: const EdgeInsets.all(16.0),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Center(
                      child: Text(
                        'Container 2',
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
                      // TODO: Handle button press for Container 3
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
                      // TODO: Handle button press for Container 4
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
