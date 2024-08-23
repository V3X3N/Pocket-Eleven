import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/bottom_nav_bar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/managers/medical_manager.dart';
import 'package:pocket_eleven/managers/scouting_manager.dart';
import 'package:pocket_eleven/managers/training_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';
import 'package:pocket_eleven/managers/youth_manager.dart';
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
      await UserManager().loadMoney();
      await TrainingManager().loadTrainingPoints();
      await MedicalManager().loadMedicalPoints();
      await YouthManager().loadYouthPoints();
      await ScoutingManager().loadScoutingLevel();
      await ScoutingManager().loadScoutingUpgradeCost();
      setState(() {});
    } catch (error) {
      debugPrint('Error loading user data: $error');
    }
  }

  void onCurrencyChange(dynamic newCurrency) {
    // Logic to handle currency change
    debugPrint("Currency changed: $newCurrency");
    _loadUserData(); // Reload user data when currency changes
  }

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
        onCurrencyChange: onCurrencyChange,
      ),
      body: _pages![_selectedIndex],
    );
  }
}
