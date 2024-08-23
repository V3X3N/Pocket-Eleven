import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  int _selectedIndex = 0;

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
      body: Container(
        color: AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OptionButton(
                    index: 0,
                    text: 'Match',
                    onTap: () => _onOptionSelected(0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  OptionButton(
                    index: 1,
                    text: 'League',
                    onTap: () => _onOptionSelected(1),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildMatchContainer(screenWidth, screenHeight),
                  _buildStandingsContainer(screenWidth, screenHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchContainer(double screenWidth, double screenHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            // TODO: First Container for the next match
            margin: EdgeInsets.all(screenWidth * 0.05),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.hoverColor,
              border: Border.all(color: AppColors.borderColor, width: 1),
              borderRadius: BorderRadius.circular(10.0),
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
                          image: AssetImage(
                              'assets/crests/crest_1.png'), // TODO: Display proper Players Club crest
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
                          image: AssetImage(
                              'assets/crests/crest_2.png'), // TODO: Display proper Players Club crest
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Text(
                      'Klub 2', // TODO: Display proper Players Club name
                      style: TextStyle(
                          color: AppColors.textEnabledColor, fontSize: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Container(
            // TODO: Second container for upcoming matches
            margin: EdgeInsets.all(screenWidth * 0.05),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.hoverColor,
              border: Border.all(color: AppColors.borderColor, width: 1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Center(
              child: Text(
                'Matches Container',
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandingsContainer(double screenWidth, double screenHeight) {
    return Container(
      // TODO: Container for league standings
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: screenWidth,
      height: screenHeight,
      child: const Center(
        child: Text(
          'Standings Container',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
