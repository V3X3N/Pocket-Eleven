import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_club.dart';
import 'package:pocket_eleven/pages/club/class/stadium_view.dart';
import 'package:pocket_eleven/pages/club/class/training_view.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({super.key});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  int _selectedIndex = 0;
  String? clubName;
  Map<String, int>? sectorLevel;
  bool _isLoading = true;
  String? _error;

  // Cache expensive calculations
  late double _screenHeight;
  late double _screenWidth;
  late double _appBarHeight;
  late EdgeInsets _mainPadding;
  late double _buttonSpacing;

  // Cache views to prevent recreation
  late final Widget _stadiumView;
  late final Widget _trainingView;

  @override
  void initState() {
    super.initState();
    _stadiumView = const StadiumView();
    _trainingView = const TrainingView();
    _getClubData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache screen dimensions and calculations
    final size = MediaQuery.of(context).size;
    _screenHeight = size.height;
    _screenWidth = size.width;
    _appBarHeight = _screenHeight * 0.07;
    _mainPadding = EdgeInsets.symmetric(
      horizontal: _screenWidth * 0.04,
      vertical: _screenHeight * 0.02,
    );
    _buttonSpacing = _screenWidth * 0.04;
  }

  Future<void> _getClubData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'No user is logged in';
          _isLoading = false;
        });
        return;
      }

      final userId = currentUser.uid;
      final firestore = FirebaseFirestore.instance;
      final userDocRef = firestore.collection('users').doc(userId);

      final userData = await ClubFunctions.getUserData(userId);

      if (userData == null) {
        setState(() {
          _error = 'User document not found';
          _isLoading = false;
        });
        return;
      }

      final fetchedClubName = userData['clubName'] as String?;
      final fetchedSectorLevel = await ClubFunctions.initializeSectorLevels(
        userDocRef,
        userData,
      );

      if (mounted) {
        setState(() {
          clubName = fetchedClubName;
          sectorLevel = fetchedSectorLevel;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error fetching club data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onOptionSelected(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: _appBarHeight),
      body: Container(
        color: AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RepaintBoundary(
              child: _buildOptionButtons(),
            ),
            Expanded(
              child: RepaintBoundary(
                child: IndexedStack(
                  index: _selectedIndex,
                  children: [_stadiumView, _trainingView],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: _appBarHeight),
      body: Container(
        color: AppColors.primaryColor,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: _appBarHeight),
      body: Container(
        color: AppColors.primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _getClubData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButtons() {
    return Padding(
      padding: _mainPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OptionButton(
            index: 0,
            text: 'Stadium',
            onTap: () => _onOptionSelected(0),
            screenWidth: _screenWidth,
            screenHeight: _screenHeight,
            selectedIndex: _selectedIndex,
          ),
          SizedBox(width: _buttonSpacing),
          OptionButton(
            index: 1,
            text: 'Training',
            onTap: () => _onOptionSelected(1),
            screenWidth: _screenWidth,
            screenHeight: _screenHeight,
            selectedIndex: _selectedIndex,
          ),
        ],
      ),
    );
  }
}
