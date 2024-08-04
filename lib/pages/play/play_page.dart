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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: screenHeight * 0.01,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.all(screenWidth * 0.05),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
                image: const DecorationImage(
                  image: AssetImage('assets/background/next_match_banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
              height: screenHeight * 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: screenWidth * 0.225,
                        width: screenWidth * 0.225,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.025),
                          image: const DecorationImage(
                            image: AssetImage('assets/crests/crest_1.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      const Text(
                        "ClubName", // TODO: Display proper Players Club name
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
                        height: screenWidth * 0.225,
                        width: screenWidth * 0.225,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.025),
                          image: const DecorationImage(
                            image: AssetImage('assets/crests/crest_2.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
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
          SizedBox(height: screenHeight * 0.02),
          Container(
            margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            height: screenHeight * 0.1,
            child: MaterialButton(
              onPressed: () {
                // TODO: Handle button press for PLAY
              },
              padding: EdgeInsets.all(screenWidth * 0.04),
              color: AppColors.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.025),
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
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.025,
                      top: screenWidth * 0.025),
                  child: MaterialButton(
                    onPressed: () {
                      // TODO: Handle button press for Container 1
                    },
                    height: screenHeight * 0.15,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
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
                  margin: EdgeInsets.only(
                      right: screenWidth * 0.05,
                      left: screenWidth * 0.025,
                      top: screenWidth * 0.025),
                  child: MaterialButton(
                    onPressed: () {
                      // TODO: Handle button press for Container 2
                    },
                    height: screenHeight * 0.15,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
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
          SizedBox(height: screenHeight * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      left: screenWidth * 0.05,
                      right: screenWidth * 0.025,
                      top: screenWidth * 0.025),
                  child: MaterialButton(
                    onPressed: () {
                      // TODO: Handle button press for Container 3
                    },
                    height: screenHeight * 0.15,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
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
                  margin: EdgeInsets.only(
                      right: screenWidth * 0.05,
                      left: screenWidth * 0.025,
                      top: screenWidth * 0.025),
                  child: MaterialButton(
                    onPressed: () {
                      // TODO: Handle button press for Container 4
                    },
                    height: screenHeight * 0.15,
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    color: AppColors.hoverColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.025),
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
