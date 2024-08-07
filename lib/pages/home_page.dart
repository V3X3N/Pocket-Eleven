import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/bottom_nav_bar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/profile/profile_page.dart';
import 'tactic/tactic_page.dart';
import 'play/play_page.dart';
import 'club/club_page.dart';
import 'transfers/transfer_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //navigate bottom bar
  int _selectedIndex = 0;
  void navigateBottomBar(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  //pages to display
  final List<Widget> _pages = [
    //Stadium page
    const ClubPage(),
    //Play page
    const PlayPage(),
    //Transfer page
    const TransferPage(),
    //League page
    const TacticPage(),
    //Profile page
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double navBarHeight = screenHeight * 0.08;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
        navBarHeight: navBarHeight,
        screenWidth: screenWidth,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
