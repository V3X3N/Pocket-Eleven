import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_players.dart';
import 'package:pocket_eleven/firebase/firebase_training.dart';
import 'package:pocket_eleven/pages/club/widget/build_info.dart';
import 'package:pocket_eleven/models/player.dart';

class TrainingView extends StatefulWidget {
  const TrainingView({super.key});

  @override
  State<TrainingView> createState() => _TrainingViewState();
}

class _TrainingViewState extends State<TrainingView> {
  static const int _maxLevel = 5;
  static const int _maxParamValue = 99;
  static const int _basePlayerTrainingCost = 10000;
  static const int _trainingCostReduction = 500;

  int _level = 1;
  int _upgradeCost = 100000;
  double _userMoney = 0;
  String? _userId;
  List<Player> _players = [];
  bool _isLoading = true;
  bool _isUpgrading = false;
  final Map<String, bool> _trainingInProgress = {};

  // Cache layout values
  double _screenWidth = 0;
  double _screenHeight = 0;
  double _horizontalPadding = 0;
  double _verticalPadding = 0;

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height;
    _horizontalPadding = _screenWidth * 0.05;
    _verticalPadding = _screenHeight * 0.02;
  }

  // Load user data and players in parallel
  Future<void> _loadData() async {
    if (_userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final futures = await Future.wait([
        FirebaseFunctions.getUserData(),
        TrainingFunctions.getTrainingLevel(_userId!),
        _loadPlayersData(),
      ]);

      final userData = futures[0] as Map<String, dynamic>;
      final trainingLevel = futures[1] as int;
      final playersList = futures[2] as List<Player>;

      if (mounted) {
        setState(() {
          _level = trainingLevel;
          _upgradeCost = FirebaseFunctions.calculateUpgradeCost(_level);
          _userMoney = (userData['money'] ?? 0).toDouble();
          _players = playersList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<List<Player>> _loadPlayersData() async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(_userId!);
    final snapshot = await FirebaseFirestore.instance
        .collection('players')
        .where('userRef', isEqualTo: userRef)
        .get();

    return snapshot.docs.map((doc) => Player.fromDocument(doc)).toList();
  }

  Future<void> _trainPlayer(Player player, String paramName) async {
    final trainingKey = '${player.playerID}_$paramName';

    if (_trainingInProgress[trainingKey] == true) return;

    final currentValue = _getParamValue(player, paramName);
    if (currentValue >= _maxParamValue) {
      _showSnackBar(
          'This attribute is already at the maximum level ($_maxParamValue).',
          Colors.red);
      return;
    }

    final trainingCost =
        max(_basePlayerTrainingCost - _trainingCostReduction * (_level - 1), 0);

    if (_userMoney < trainingCost) {
      _showSnackBar('Not enough money for training.', Colors.red);
      return;
    }

    setState(() => _trainingInProgress[trainingKey] = true);

    try {
      final newValue = min(currentValue + 1, _maxParamValue);
      _setParamValue(player, paramName, newValue);
      player.updateDerivedAttributes();

      await Future.wait([
        PlayerFunctions.updatePlayerData(player.playerID, player.toDocument()),
        FirebaseFunctions.updateUserData({'money': _userMoney - trainingCost}),
      ]);

      if (mounted) {
        setState(() {
          _userMoney -= trainingCost;
          _trainingInProgress.remove(trainingKey);
        });
      }
    } catch (e) {
      debugPrint('Error training player: $e');
      _showSnackBar('Training failed. Please try again.', Colors.red);
      if (mounted) setState(() => _trainingInProgress.remove(trainingKey));
    }
  }

  Future<void> _increaseLevel() async {
    if (_isUpgrading || _level >= _maxLevel) {
      if (_level >= _maxLevel) {
        _showSnackBar('Training is already at the maximum level ($_maxLevel).',
            Colors.orange);
      }
      return;
    }

    if (_userMoney < _upgradeCost) {
      _showSnackBar('Not enough money to upgrade the training.', Colors.red);
      return;
    }

    setState(() => _isUpgrading = true);

    try {
      final newLevel = _level + 1;
      await Future.wait([
        TrainingFunctions.updateTrainingLevel(_userId!, newLevel),
        FirebaseFunctions.updateUserData({'money': _userMoney - _upgradeCost}),
      ]);

      if (mounted) {
        setState(() {
          _level = newLevel;
          _userMoney -= _upgradeCost;
          _upgradeCost = FirebaseFunctions.calculateUpgradeCost(_level);
          _isUpgrading = false;
        });
      }
    } catch (e) {
      debugPrint('Error upgrading training: $e');
      _showSnackBar('Upgrade failed. Please try again.', Colors.red);
      if (mounted) setState(() => _isUpgrading = false);
    }
  }

  int _getParamValue(Player player, String paramName) {
    switch (paramName) {
      case 'param1':
        return player.param1;
      case 'param2':
        return player.param2;
      case 'param3':
        return player.param3;
      case 'param4':
        return player.param4;
      default:
        return 0;
    }
  }

  void _setParamValue(Player player, String paramName, int value) {
    switch (paramName) {
      case 'param1':
        player.param1 = value;
        break;
      case 'param2':
        player.param2 = value;
        break;
      case 'param3':
        player.param3 = value;
        break;
      case 'param4':
        player.param4 = value;
        break;
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get layout values directly if not cached yet
    final screenWidth =
        _screenWidth > 0 ? _screenWidth : MediaQuery.of(context).size.width;
    final screenHeight =
        _screenHeight > 0 ? _screenHeight : MediaQuery.of(context).size.height;
    final horizontalPadding =
        _horizontalPadding > 0 ? _horizontalPadding : screenWidth * 0.05;
    final verticalPadding =
        _verticalPadding > 0 ? _verticalPadding : screenHeight * 0.02;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TrainingInfoContainer(
                    level: _level,
                    upgradeCost: _upgradeCost,
                    userMoney: _userMoney,
                    isUpgrading: _isUpgrading,
                    onUpgradePressed: _increaseLevel,
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  _isLoading
                      ? Center(
                          child: LoadingAnimationWidget.waveDots(
                            color: AppColors.textEnabledColor,
                            size: 50,
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _players.length,
                            itemBuilder: (context, index) => _PlayerCard(
                              player: _players[index],
                              screenWidth: screenWidth,
                              screenHeight: screenHeight,
                              trainingInProgress: _trainingInProgress,
                              onTrainPlayer: _trainPlayer,
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainingInfoContainer extends StatelessWidget {
  const _TrainingInfoContainer({
    required this.level,
    required this.upgradeCost,
    required this.userMoney,
    required this.isUpgrading,
    required this.onUpgradePressed,
  });

  final int level;
  final int upgradeCost;
  final double userMoney;
  final bool isUpgrading;
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
        child: BuildInfo(
          headerText: 'Training',
          level: level,
          upgradeCost: upgradeCost,
          isUpgradeEnabled: userMoney >= upgradeCost && !isUpgrading,
          onUpgradePressed: onUpgradePressed,
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({
    required this.player,
    required this.screenWidth,
    required this.screenHeight,
    required this.trainingInProgress,
    required this.onTrainPlayer,
  });

  final Player player;
  final double screenWidth;
  final double screenHeight;
  final Map<String, bool> trainingInProgress;
  final Function(Player, String) onTrainPlayer;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.01),
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              player.name,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.bold,
                color: AppColors.textEnabledColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TrainingButton(
                  player: player,
                  paramName: 'param1',
                  paramLabel: player.param1Name,
                  paramValue: player.param1,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isTraining:
                      trainingInProgress['${player.playerID}_param1'] ?? false,
                  onTrain: () => onTrainPlayer(player, 'param1'),
                ),
                _TrainingButton(
                  player: player,
                  paramName: 'param2',
                  paramLabel: player.param2Name,
                  paramValue: player.param2,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isTraining:
                      trainingInProgress['${player.playerID}_param2'] ?? false,
                  onTrain: () => onTrainPlayer(player, 'param2'),
                ),
                _TrainingButton(
                  player: player,
                  paramName: 'param3',
                  paramLabel: player.param3Name,
                  paramValue: player.param3,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isTraining:
                      trainingInProgress['${player.playerID}_param3'] ?? false,
                  onTrain: () => onTrainPlayer(player, 'param3'),
                ),
                _TrainingButton(
                  player: player,
                  paramName: 'param4',
                  paramLabel: player.param4Name,
                  paramValue: player.param4,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  isTraining:
                      trainingInProgress['${player.playerID}_param4'] ?? false,
                  onTrain: () => onTrainPlayer(player, 'param4'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingButton extends StatelessWidget {
  const _TrainingButton({
    required this.player,
    required this.paramName,
    required this.paramLabel,
    required this.paramValue,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTraining,
    required this.onTrain,
  });

  final Player player;
  final String paramName;
  final String paramLabel;
  final int paramValue;
  final double screenWidth;
  final double screenHeight;
  final bool isTraining;
  final VoidCallback onTrain;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$paramLabel: $paramValue',
            style: TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: screenWidth * 0.030,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          OptionButton(
            onTap: isTraining ? null : onTrain,
            screenWidth: screenWidth,
            screenHeight: screenHeight * 0.7,
            text: isTraining ? 'Training...' : 'Train',
            fontSizeMultiplier: 0.7,
          ),
        ],
      ),
    );
  }
}
