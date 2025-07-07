import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_confirm_widget.dart';

class ScoutingView extends StatefulWidget {
  const ScoutingView({super.key, required this.onCurrencyChange});
  final VoidCallback onCurrencyChange;

  @override
  State<ScoutingView> createState() => _ScoutingViewState();
}

class _ScoutingViewState extends State<ScoutingView>
    with TickerProviderStateMixin {
  // Core state variables
  int _level = 1;
  int _upgradeCost = 200000;
  double _userMoney = 0;
  String? _userId;
  String _selectedPosition = 'LW';
  String _selectedNationality = 'AUT';
  final bool _canScout = true;
  bool _isLoading = false;
  List<Player> _scoutedPlayers = [];
  Player? _selectedPlayer;
  Duration? _remainingTime;
  Timer? _countdownTimer;

  // Animation controllers
  late AnimationController _upgradeButtonController;
  late AnimationController _scoutButtonController;
  late Animation<double> _scaleAnimation;

  // Constants for performance
  static const List<String> _positions = [
    'LW',
    'ST',
    'RW',
    'LM',
    'CAM',
    'CM',
    'CDM',
    'RM',
    'LB',
    'CB',
    'RB',
    'GK'
  ];

  static const List<String> _nationalities = [
    'AUT',
    'BEL',
    'ENG',
    'ESP',
    'FRA',
    'GER',
    'ITA',
    'POL',
    'TUR',
    'USA',
    'BRA',
    'JPN',
  ];

  // Cached widgets for performance
  late final Widget _titleWidget;

  double get _scoutingTimeReductionPercentage {
    if (_level > 1) {
      return 7 * (_level - 1).toDouble();
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCachedWidgets();
    _initializeData();
  }

  void _initializeAnimations() {
    _upgradeButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scoutButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _upgradeButtonController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeCachedWidgets() {
    _titleWidget = const Text(
      'Scouting',
      style: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: AppColors.textEnabledColor,
      ),
    );
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadUserData(),
        _loadSelectedPositionAndNationality(),
        _loadScoutedPlayers(),
      ]);

      await _fetchPlayersFromScouting();
    } catch (e) {
      debugPrint('Error initializing data: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to load data. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _upgradeButtonController.dispose();
    _scoutButtonController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRefreshData() async {
    if (!mounted || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showErrorSnackBar('User is not logged in.');
        return;
      }

      final scoutingRef =
          FirebaseFirestore.instance.collection('scouting').doc(user.uid);
      final scoutingDoc = await scoutingRef.get();

      if (scoutingDoc.exists) {
        await _refreshData();
      } else {
        debugPrint('No document found. Generating new data.');
        await _generateAndSavePlayers();
        await _checkAndRefreshData();
      }
    } catch (e) {
      debugPrint('Error checking and refreshing data: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to refresh data. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final scoutingRef =
          FirebaseFirestore.instance.collection('scouting').doc(user.uid);
      final scoutingDoc = await scoutingRef.get();

      if (!scoutingDoc.exists) return;

      final List<dynamic> playerRefs = scoutingDoc.data()?['playerRefs'] ?? [];

      // Use batch operations for better performance
      final batch = FirebaseFirestore.instance.batch();
      for (var ref in playerRefs) {
        if (ref is DocumentReference) {
          batch.delete(ref);
        }
      }
      await batch.commit();

      await _generateAndSavePlayers();

      if (mounted) {
        setState(() {
          _scoutedPlayers.clear();
          _remainingTime = null;
        });
      }

      final newScoutingDoc = await scoutingRef.get();
      if (newScoutingDoc.exists && newScoutingDoc.data()?['showAt'] != null) {
        await _startCountdownTimer(newScoutingDoc.data()!['showAt']);
      }
    } catch (e) {
      debugPrint('Error refreshing data: $e');
      rethrow;
    }
  }

  Future<void> _generateAndSavePlayers() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User is not logged in.');
      }

      final tempScoutingRef =
          FirebaseFirestore.instance.collection('temp_scouting');
      final scoutingRef =
          FirebaseFirestore.instance.collection('scouting').doc(user.uid);

      List<DocumentReference> playerRefs = [];
      final DateTime currentLocalTime = DateTime.now();
      final Timestamp createdAt = Timestamp.fromDate(currentLocalTime);

      // Generate players in parallel for better performance
      final futures = List.generate(3, (i) async {
        final player = await Player.generateRandomFootballer(
          nationality: _selectedNationality,
          position: _selectedPosition,
        );
        final playerDocRef = tempScoutingRef.doc();
        await playerDocRef.set(player.toDocument());
        return playerDocRef;
      });

      playerRefs = await Future.wait(futures);

      // Calculate show time with level-based reduction
      final baseWaitTime = const Duration(minutes: 4);
      final reductionSeconds =
          (baseWaitTime.inSeconds * _scoutingTimeReductionPercentage / 100)
              .round();
      final actualWaitTime =
          Duration(seconds: baseWaitTime.inSeconds - reductionSeconds);

      final DateTime showDate = currentLocalTime.add(actualWaitTime);
      final Timestamp showAt = Timestamp.fromDate(showDate);

      await scoutingRef.set({
        'playerRefs': playerRefs,
        'createdAt': createdAt,
        'showAt': showAt,
      });

      debugPrint(
          'New scouting document created with ${playerRefs.length} players');
    } catch (e) {
      debugPrint('Error generating and saving players: $e');
      rethrow;
    }
  }

  Future<void> _fetchPlayersFromScouting() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final scoutingRef =
          FirebaseFirestore.instance.collection('scouting').doc(user.uid);
      final scoutingDoc = await scoutingRef.get();

      if (!scoutingDoc.exists) return;

      final data = scoutingDoc.data();
      if (data == null) return;

      final List<dynamic> playerRefs = data['playerRefs'] ?? [];
      final Timestamp? showAt = data['showAt'];

      if (showAt != null) {
        await _startCountdownTimer(showAt);
      }

      if (playerRefs.isNotEmpty) {
        final futures = playerRefs.map((ref) async {
          if (ref is DocumentReference) {
            final playerDoc = await ref.get();
            if (playerDoc.exists) {
              return Player.fromDocument(playerDoc);
            }
          }
          return null;
        });

        final players = await Future.wait(futures);
        final validPlayers =
            players.where((p) => p != null).cast<Player>().toList();

        if (mounted) {
          setState(() {
            _scoutedPlayers = validPlayers;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching players from scouting: $e');
    }
  }

  Future<void> _startCountdownTimer(Timestamp showAt) async {
    final DateTime now = DateTime.now();
    final DateTime showTime = showAt.toDate();
    final Duration duration = showTime.difference(now);

    if (duration.isNegative) {
      if (mounted) {
        setState(() => _remainingTime = null);
      }
      return;
    }

    if (mounted) {
      setState(() => _remainingTime = duration);
    }

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final remaining = showTime.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        setState(() => _remainingTime = null);
        _fetchPlayersFromScouting();
      } else {
        setState(() => _remainingTime = remaining);
      }
    });
  }

  Future<void> _removePlayerFromList(Player player) async {
    try {
      setState(() {
        _scoutedPlayers.removeWhere((p) => p.playerID == player.playerID);
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final scoutingRef =
          FirebaseFirestore.instance.collection('scouting').doc(user.uid);
      final tempScoutingRef = FirebaseFirestore.instance
          .collection('temp_scouting')
          .doc(player.playerID);

      await Future.wait([
        scoutingRef.update({
          'playerRefs': FieldValue.arrayRemove([tempScoutingRef])
        }),
        tempScoutingRef.delete(),
      ]);
    } catch (e) {
      debugPrint('Error removing player from list: $e');
    }
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _userId = user.uid;
      final userData = await FirebaseFunctions.getUserData();
      final newLevel = userData['scoutingLevel'] ?? 1;

      if (mounted) {
        setState(() {
          _level = newLevel;
          _upgradeCost = FirebaseFunctions.calculateUpgradeCost(_level);
          _userMoney = (userData['money'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      rethrow;
    }
  }

  Future<void> _loadSelectedPositionAndNationality() async {
    if (_userId == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId!)
          .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data() ?? {};

      if (mounted) {
        setState(() {
          _selectedPosition = userData['selectedPosition'] ?? 'LW';
          _selectedNationality = userData['selectedNationality'] ?? 'AUT';
        });
      }
    } catch (e) {
      debugPrint('Error loading selected position and nationality: $e');
    }
  }

  Future<void> _loadScoutedPlayers() async {
    if (_userId == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('scouting')
          .doc(_userId!)
          .collection('players')
          .get();

      if (mounted) {
        setState(() {
          _scoutedPlayers =
              snapshot.docs.map((doc) => Player.fromDocument(doc)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading scouted players: $e');
    }
  }

  Future<void> _increaseLevel() async {
    if (_level >= 5) {
      _showInfoSnackBar(
          'Scouting is already at the maximum level (5).', Colors.orange);
      return;
    }

    if (_userId == null) return;

    try {
      final userDoc = await FirebaseFunctions.getUserDocument(_userId!);
      final userData = userDoc.data() as Map<String, dynamic>? ?? {};
      final userMoney = (userData['money'] ?? 0).toDouble();
      final currentLevel = userData['scoutingLevel'] ?? 1;

      final currentUpgradeCost =
          FirebaseFunctions.calculateUpgradeCost(currentLevel);

      if (userMoney >= currentUpgradeCost) {
        final newLevel = currentLevel + 1;

        await FirebaseFunctions.updateUserData({
          'scoutingLevel': newLevel,
          'money': userMoney - currentUpgradeCost,
        });

        if (mounted) {
          setState(() {
            _level = newLevel;
            _upgradeCost = FirebaseFunctions.calculateUpgradeCost(newLevel);
            _userMoney = userMoney - currentUpgradeCost;
          });
        }

        widget.onCurrencyChange();
        _showInfoSnackBar(
            'Scouting upgraded to level $newLevel!', Colors.green);
      } else {
        _showInfoSnackBar('Not enough money to upgrade scouting.', Colors.red);
      }
    } catch (e) {
      debugPrint('Error upgrading scouting: $e');
      _showErrorSnackBar('Failed to upgrade scouting. Please try again.');
    }
  }

  Future<void> _saveSelectedPosition(String position) async {
    if (_userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId!)
          .update({'selectedPosition': position});
    } catch (e) {
      debugPrint('Error saving selected position: $e');
    }
  }

  Future<void> _saveSelectedNationality(String nationality) async {
    if (_userId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId!)
          .update({'selectedNationality': nationality});
    } catch (e) {
      debugPrint('Error saving selected nationality: $e');
    }
  }

  void _showInfoSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    _showInfoSnackBar(message, Colors.red);
  }

  Widget _buildScoutInfo(double screenWidth, double screenHeight) {
    final reductionPercentage = _scoutingTimeReductionPercentage;

    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titleWidget,
                const SizedBox(height: 4),
                _buildLevelInfo(reductionPercentage),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildUpgradeButton(screenWidth, screenHeight),
                const SizedBox(height: 8.0),
                _buildCostText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInfo(double reductionPercentage) {
    return Tooltip(
      triggerMode: TooltipTriggerMode.tap,
      message:
          'Current time reduction: ${reductionPercentage.toStringAsFixed(0)}%',
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Level $_level',
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textEnabledColor,
            ),
          ),
          const SizedBox(width: 4.0),
          const Icon(
            Icons.info_outline,
            color: AppColors.textEnabledColor,
            size: 16.0,
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton(double screenWidth, double screenHeight) {
    final canUpgrade = _userMoney >= _upgradeCost && _level < 5;

    return AnimatedBuilder(
      animation: _upgradeButtonController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown:
                canUpgrade ? (_) => _upgradeButtonController.forward() : null,
            onTapUp:
                canUpgrade ? (_) => _upgradeButtonController.reverse() : null,
            onTapCancel:
                canUpgrade ? () => _upgradeButtonController.reverse() : null,
            onTap: canUpgrade ? _increaseLevel : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.01,
                horizontal: screenWidth * 0.05,
              ),
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: AppColors.borderColor),
                color: canUpgrade ? AppColors.blueColor : AppColors.buttonColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: canUpgrade
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        )
                      ]
                    : [],
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.textEnabledColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCostText() {
    return Text(
      'Cost: $_upgradeCost',
      style: const TextStyle(
        color: AppColors.textEnabledColor,
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildPositionSelector() {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Position',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textEnabledColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _positions.length,
              itemBuilder: (context, index) {
                final position = _positions[index];
                final isSelected = _selectedPosition == position;

                return RepaintBoundary(
                  child: GestureDetector(
                    onTap: _canScout
                        ? () {
                            setState(() {
                              _selectedPosition = position;
                            });
                            _saveSelectedPosition(position);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.blueColor
                            : AppColors.buttonColor,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.blueColor
                              : AppColors.borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.blueColor
                                      .withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          position,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: AppColors.textEnabledColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNationalitySelector() {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Nationality',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textEnabledColor,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _nationalities.length,
              itemBuilder: (context, index) {
                final countryCode = _nationalities[index];
                final isSelected = _selectedNationality == countryCode;

                return RepaintBoundary(
                  child: GestureDetector(
                    onTap: _canScout
                        ? () {
                            setState(() {
                              _selectedNationality = countryCode;
                            });
                            _saveSelectedNationality(countryCode);
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? AppColors.blueColor
                              : AppColors.borderColor,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12.0),
                        color: isSelected
                            ? AppColors.blueColor
                            : AppColors.buttonColor,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.blueColor
                                      .withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/flags/flag_$countryCode.png',
                          width: 30,
                          height: 20,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              countryCode,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textEnabledColor,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoutedPlayersList(double screenWidth, double screenHeight) {
    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scouted Players',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.textEnabledColor,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            if (_remainingTime != null)
              _buildCountdownWidget()
            else if (_scoutedPlayers.isEmpty)
              const Center(
                child: Text(
                  'No players scouted yet.',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.textEnabledColor,
                  ),
                ),
              )
            else
              _buildPlayersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownWidget() {
    final String timeFormatted = _remainingTime != null
        ? '${_remainingTime!.inMinutes}:${(_remainingTime!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '0:00';

    return Center(
      child: Column(
        children: [
          const Icon(
            Icons.timer,
            size: 48,
            color: AppColors.textEnabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Players will be shown in',
            style: TextStyle(
              fontSize: 16.0,
              color: AppColors.textEnabledColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeFormatted,
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textEnabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _scoutedPlayers.length,
      itemBuilder: (context, index) {
        final player = _scoutedPlayers[index];
        return RepaintBoundary(
          child: TransferPlayerConfirmWidget(
            player: player,
            isSelected: _selectedPlayer == player,
            onPlayerSelected: (selectedPlayer) {
              setState(() {
                _selectedPlayer = selectedPlayer;
              });
              _removePlayerFromList(selectedPlayer);
            },
          ),
        );
      },
    );
  }

  Widget _buildScoutButton(double screenHeight) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _scoutButtonController,
        builder: (context, child) {
          return GestureDetector(
            onTapDown: _canScout && !_isLoading
                ? (_) => _scoutButtonController.forward()
                : null,
            onTapUp: _canScout && !_isLoading
                ? (_) => _scoutButtonController.reverse()
                : null,
            onTapCancel: _canScout && !_isLoading
                ? () => _scoutButtonController.reverse()
                : null,
            onTap: _canScout && !_isLoading
                ? () async {
                    setState(() {
                      _scoutedPlayers.clear();
                      _remainingTime = null;
                    });
                    await _checkAndRefreshData();
                  }
                : null,
            child: Transform.scale(
              scale: _scoutButtonController.value == 1.0 ? 0.95 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                  horizontal: 32.0,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: _canScout && !_isLoading
                        ? AppColors.blueColor
                        : AppColors.borderColor,
                  ),
                  color: _canScout && !_isLoading
                      ? AppColors.blueColor
                      : AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _canScout && !_isLoading
                      ? [
                          BoxShadow(
                            color: AppColors.blueColor.withValues(alpha: 0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textEnabledColor),
                        ),
                      )
                    else
                      const Icon(
                        Icons.search,
                        color: AppColors.textEnabledColor,
                        size: 20,
                      ),
                    const SizedBox(width: 8),
                    Text(
                      _isLoading ? 'Scouting...' : 'Scout',
                      style: const TextStyle(
                        fontSize: 18.0,
                        color: AppColors.textEnabledColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContainer({
    required Widget child,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenHeight * 0.02,
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading && _scoutedPlayers.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blueColor),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // Scout Info Section
          _buildContainer(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            child: _buildScoutInfo(screenWidth, screenHeight),
          ),

          // Position and Nationality Selection
          _buildContainer(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPositionSelector(),
                SizedBox(height: screenHeight * 0.03),
                _buildNationalitySelector(),
              ],
            ),
          ),

          // Scouted Players List
          _buildScoutedPlayersList(screenWidth, screenHeight),

          // Scout Button
          SizedBox(height: screenHeight * 0.01),
          _buildScoutButton(screenHeight),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}
