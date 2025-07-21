import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/firebase/firebase_stadium.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_build.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_info.dart';

class StadiumView extends StatefulWidget {
  const StadiumView({super.key});

  @override
  StadiumViewState createState() => StadiumViewState();
}

class StadiumViewState extends State<StadiumView> {
  static const int _maxLevel = 5;
  static const Duration _snackBarDuration = Duration(seconds: 2);
  static const Duration _shortSnackBarDuration = Duration(seconds: 1);

  int _level = 1;
  int _upgradeCost = 100000;
  double _userMoney = 0;
  String? _userId;
  bool _isLoading = true;
  bool _isUpgrading = false;
  Map<String, int>? _sectorLevel;

  // Cache frequently accessed values
  late final String? _cachedUserId;

  // Precompute layout constants
  late final double _horizontalPadding;
  late final double _verticalPadding;

  @override
  void initState() {
    super.initState();
    _cachedUserId = FirebaseAuth.instance.currentUser?.uid;
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache layout values to avoid repeated MediaQuery calls
    final size = MediaQuery.of(context).size;
    _horizontalPadding = size.width * 0.05;
    _verticalPadding = size.height * 0.02;
  }

  Future<void> _loadUserData() async {
    if (_cachedUserId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Use parallel execution for independent operations
      final futures = await Future.wait([
        FirebaseFunctions.getUserData(),
        StadiumFunctions.getStadiumLevel(_cachedUserId),
      ]);

      final userData = futures[0] as Map<String, dynamic>;
      final stadiumLevel = futures[1] as int;

      // Batch state updates to minimize rebuilds
      if (mounted) {
        setState(() {
          _userId = _cachedUserId;
          _level = stadiumLevel;
          _upgradeCost = FirebaseFunctions.calculateUpgradeCost(_level);
          _userMoney = (userData['money'] ?? 0).toDouble();
          _sectorLevel = userData.containsKey('sectorLevel')
              ? Map<String, int>.from(userData['sectorLevel'])
              : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _increaseLevel() async {
    if (_isUpgrading || _level >= _maxLevel) {
      if (_level >= _maxLevel) {
        _showSnackBar(
          'Stadium is already at the maximum level ($_maxLevel).',
          Colors.orange,
          _snackBarDuration,
        );
      }
      return;
    }

    if (_userMoney < _upgradeCost) {
      _showSnackBar(
        'Not enough money to upgrade the stadium.',
        Colors.red,
        _shortSnackBarDuration,
      );
      return;
    }

    setState(() => _isUpgrading = true);

    try {
      final newLevel = _level + 1;
      final newMoney = _userMoney - _upgradeCost;
      final newUpgradeCost = FirebaseFunctions.calculateUpgradeCost(newLevel);

      // Perform database operations
      await Future.wait([
        StadiumFunctions.updateStadiumLevel(_userId!, newLevel),
        FirebaseFunctions.updateUserData({'money': newMoney}),
      ]);

      // Update UI only after successful database operations
      if (mounted) {
        setState(() {
          _level = newLevel;
          _userMoney = newMoney;
          _upgradeCost = newUpgradeCost;
          _isUpgrading = false;
        });
      }
    } catch (e) {
      debugPrint('Error upgrading stadium: $e');
      if (mounted) {
        setState(() => _isUpgrading = false);
      }
      _showSnackBar(
        'Failed to upgrade stadium. Please try again.',
        Colors.red,
        _snackBarDuration,
      );
    }
  }

  void _showSnackBar(String message, Color backgroundColor, Duration duration) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: _horizontalPadding,
                vertical: _verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StadiumInfoContainer(
                    level: _level,
                    upgradeCost: _upgradeCost,
                    userMoney: _userMoney,
                    isUpgrading: _isUpgrading,
                    sectorLevel: _sectorLevel,
                    onUpgradePressed: _increaseLevel,
                  ),
                  const SizedBox(height: 20.0),
                  const Expanded(child: StadiumBuild()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Extract stadium info container to reduce widget tree complexity
class _StadiumInfoContainer extends StatelessWidget {
  const _StadiumInfoContainer({
    required this.level,
    required this.upgradeCost,
    required this.userMoney,
    required this.isUpgrading,
    required this.sectorLevel,
    required this.onUpgradePressed,
  });

  final int level;
  final int upgradeCost;
  final double userMoney;
  final bool isUpgrading;
  final Map<String, int>? sectorLevel;
  final VoidCallback onUpgradePressed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: StadiumInfo(
          headerText: 'Stadium',
          level: level,
          upgradeCost: upgradeCost,
          isUpgradeEnabled: userMoney >= upgradeCost && !isUpgrading,
          onUpgradePressed: onUpgradePressed,
          sectorLevel: sectorLevel,
        ),
      ),
    );
  }
}
