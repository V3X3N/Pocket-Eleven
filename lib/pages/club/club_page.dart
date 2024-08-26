import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/class/medical_view.dart';
import 'package:pocket_eleven/pages/club/class/stadium_view.dart';
import 'package:pocket_eleven/pages/club/class/training_view.dart';
import 'package:pocket_eleven/pages/club/class/youth_view.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({super.key});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OptionButton(
                      index: 0,
                      text: 'Stadium',
                      onTap: () => _onOptionSelected(0),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      selectedIndex: _selectedIndex,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    OptionButton(
                      index: 1,
                      text: 'Training',
                      onTap: () => _onOptionSelected(1),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      selectedIndex: _selectedIndex,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    OptionButton(
                      index: 2,
                      text: 'Medical',
                      onTap: () => _onOptionSelected(2),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      selectedIndex: _selectedIndex,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    OptionButton(
                      index: 3,
                      text: 'Youth',
                      onTap: () => _onOptionSelected(3),
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                      selectedIndex: _selectedIndex,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [
                  StadiumView(),
                  TrainingView(),
                  MedicalView(),
                  YouthView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
