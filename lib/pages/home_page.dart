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
  int _selectedIndex = 0;

  List<Widget>? _pages;

  @override
  void initState() {
    super.initState();

    // Initialize the pages inside initState
    _pages = [
      // Stadium page
      const ClubPage(),
      // Play page
      const PlayPage(),
      // Transfer page
      TransferPage(onCurrencyChange: _loadUserData),
      // League page
      const TacticPage(),
      // Profile page
      const ProfilePage(),
    ];

    // Load user data
    _loadUserData();
  }

  void navigateBottomBar(int newIndex) {
    setState(() {
      _selectedIndex = newIndex;
    });
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {});
    } catch (error) {
      debugPrint('Error loading user data: $error');
    }
  }

  void onCurrencyChange(dynamic newCurrency) {
    debugPrint("Currency changed: $newCurrency");
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: _pages![_selectedIndex],
    );
  }
}
