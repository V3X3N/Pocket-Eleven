import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/bottom_nav_bar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/profile_page.dart';

import 'league_page.dart';
import 'play_page.dart';
import 'stadium_page.dart';
import 'transfer_page.dart';

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
    const StadiumPage(),

    //Play page
    const PlayPage(),

    //Transfer page
    const TransferPage(),

    //League page
    const LeaguePage(),

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
