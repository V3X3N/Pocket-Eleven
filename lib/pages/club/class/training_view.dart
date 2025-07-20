import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_players.dart';
import 'package:pocket_eleven/firebase/firebase_training.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/club/widget/loading_overlay.dart';
import 'package:pocket_eleven/pages/club/widget/player_training_card.dart';
import 'package:pocket_eleven/pages/club/widget/training_info_card.dart';

/// Optimized training view with performance improvements and reusable components
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

  @override
  void initState() {
    super.initState();
    _userId = FirebaseAuth.instance.currentUser?.uid;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final results = await Future.wait([
        FirebaseFunctions.getUserData(),
        TrainingFunctions.getTrainingLevel(_userId!),
        _loadPlayersData(),
      ]);

      if (mounted) {
        final userData = results[0] as Map<String, dynamic>;
        final trainingLevel = results[1] as int;
        final playersList = results[2] as List<Player>;

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
      _showMessage(
          'This attribute is already at the maximum level ($_maxParamValue).',
          Colors.orange);
      return;
    }

    final trainingCost =
        max(_basePlayerTrainingCost - _trainingCostReduction * (_level - 1), 0);
    if (_userMoney < trainingCost) {
      _showMessage('Not enough money for training.', Colors.red);
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
      _showMessage('Training failed. Please try again.', Colors.red);
      if (mounted) setState(() => _trainingInProgress.remove(trainingKey));
    }
  }

  Future<void> _increaseLevel() async {
    if (_isUpgrading || _level >= _maxLevel) {
      if (_level >= _maxLevel) {
        _showMessage('Training is already at the maximum level ($_maxLevel).',
            Colors.orange);
      }
      return;
    }

    if (_userMoney < _upgradeCost) {
      _showMessage('Not enough money to upgrade the training.', Colors.red);
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
      _showMessage('Upgrade failed. Please try again.', Colors.red);
      if (mounted) setState(() => _isUpgrading = false);
    }
  }

  int _getParamValue(Player player, String paramName) {
    return switch (paramName) {
      'param1' => player.param1,
      'param2' => player.param2,
      'param3' => player.param3,
      'param4' => player.param4,
      _ => 0,
    };
  }

  void _setParamValue(Player player, String paramName, int value) {
    switch (paramName) {
      case 'param1':
        player.param1 = value;
      case 'param2':
        player.param2 = value;
      case 'param3':
        player.param3 = value;
      case 'param4':
        player.param4 = value;
    }
  }

  void _showMessage(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<TrainingAttribute> _getPlayerAttributes(Player player) {
    return [
      TrainingAttribute(
        name: player.param1Name,
        value: player.param1,
        isTraining: _trainingInProgress['${player.playerID}_param1'] ?? false,
        onTrain: () => _trainPlayer(player, 'param1'),
      ),
      TrainingAttribute(
        name: player.param2Name,
        value: player.param2,
        isTraining: _trainingInProgress['${player.playerID}_param2'] ?? false,
        onTrain: () => _trainPlayer(player, 'param2'),
      ),
      TrainingAttribute(
        name: player.param3Name,
        value: player.param3,
        isTraining: _trainingInProgress['${player.playerID}_param3'] ?? false,
        onTrain: () => _trainPlayer(player, 'param3'),
      ),
      TrainingAttribute(
        name: player.param4Name,
        value: player.param4,
        isTraining: _trainingInProgress['${player.playerID}_param4'] ?? false,
        onTrain: () => _trainPlayer(player, 'param4'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.primaryColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TrainingInfoCard(
                  level: _level,
                  upgradeCost: _upgradeCost,
                  isUpgradeEnabled: _userMoney >= _upgradeCost && !_isUpgrading,
                  isUpgrading: _isUpgrading,
                  headerText: 'Training',
                  onUpgradePressed: _increaseLevel,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: LoadingOverlay(
                    isLoading: _isLoading,
                    loadingText: 'Loading players...',
                    child: ListView.builder(
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return PlayerTrainingCard(
                          playerName: player.name,
                          attributes: _getPlayerAttributes(player),
                          trainingText: 'Train',
                          trainingInProgressText: 'Training...',
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
