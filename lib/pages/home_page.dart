import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/bottom_nav_bar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/bottomNavBar/profile_page.dart';

import 'bottomNavBar/tactic_page.dart';
import 'bottomNavBar/play_page.dart';
import 'bottomNavBar/club_page.dart';
import 'bottomNavBar/transfer_page.dart';

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
    double navBarHeight = MediaQuery.of(context).size.height * 0.08;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
        navBarHeight: navBarHeight,
      ),
      body: _pages[_selectedIndex],
    );
  }
}
