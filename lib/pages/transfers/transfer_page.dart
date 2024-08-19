import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/managers/medical_manager.dart';
import 'package:pocket_eleven/managers/scouting_manager.dart';
import 'package:pocket_eleven/managers/training_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';
import 'package:pocket_eleven/managers/youth_manager.dart';
import 'package:pocket_eleven/pages/transfers/widgets/nationality_selector.dart';
import 'package:pocket_eleven/pages/transfers/widgets/position_selector.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key, required this.onCurrencyChange});
  final VoidCallback onCurrencyChange;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  int _selectedIndex = 0;
  List<Player> _players = [];
  int level = 1;
  int upgradeCost = 200000;
  String selectedPosition = 'LW';
  String selectedNationality = 'AUT';
  bool canScout = true;
  Timer? _timer;
  Duration _remainingTime = const Duration(minutes: 1);
  final Duration _scoutCooldown = const Duration(minutes: 1);
  List<Player> scoutedPlayers = [];

  double get scoutingTimeReductionPercentage {
    if (level > 1) {
      return 7 * (level - 1);
    }
    return 0;
  }

  Duration get adjustedScoutCooldown {
    final reductionPercentage = scoutingTimeReductionPercentage;
    final reductionFactor = (100 - reductionPercentage) / 100;
    return Duration(
      milliseconds: (_scoutCooldown.inMilliseconds * reductionFactor).round(),
    );
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

  Future<void> _generatePlayers() async {
    List<Player> players = [];
    for (int i = 0; i < 10; i++) {
      Player player = await Player.generateRandomFootballer();
      players.add(player);
    }
    setState(() {
      _players = players;
    });
  }

  @override
  void initState() {
    super.initState();
    level = ScoutingManager.scoutingLevel;
    upgradeCost = ScoutingManager.scoutingUpgradeCost;
    _loadSelectedPositionAndNationality();
    _loadScoutedPlayers();
    checkScoutAvailability();
    _loadUserData();
    _generatePlayers();
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadSelectedPositionAndNationality() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedPosition = prefs.getString('selectedPosition') ?? 'LW';
      selectedNationality = prefs.getString('selectedNationality') ?? 'AUT';
    });
  }

  Future<void> _loadScoutedPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getString('scoutedPlayers');
    if (playersJson != null) {
      setState(() {
        scoutedPlayers = (jsonDecode(playersJson) as List)
            .map((data) => Player.fromJson(data))
            .toList();
      });
    }
  }

  Future<void> _saveScoutedPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('scoutedPlayers', jsonEncode(scoutedPlayers));
  }

  void increaseLevel() {
    if (UserManager.money >= upgradeCost) {
      setState(() {
        level++;
        UserManager.money -= upgradeCost;
        ScoutingManager.scoutingLevel = level;
        ScoutingManager.scoutingUpgradeCost =
            ((upgradeCost * 2.3) / 10000).round() * 10000;
        upgradeCost = ScoutingManager.scoutingUpgradeCost;
      });

      widget.onCurrencyChange();

      ScoutingManager().saveScoutingLevel();
      ScoutingManager().saveScoutingUpgradeCost();
    }
  }

  Future<void> checkScoutAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScoutTime = prefs.getInt('lastScoutTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final diff = currentTime - lastScoutTime;

    if (diff < adjustedScoutCooldown.inMilliseconds) {
      setState(() {
        canScout = false;
        _remainingTime =
            Duration(milliseconds: adjustedScoutCooldown.inMilliseconds - diff);
      });
      startScoutTimer();
    } else {
      setState(() {
        canScout = true;
        _remainingTime = Duration.zero;
      });
    }
  }

  void startScoutTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _timer?.cancel();
          canScout = true;
          generatePlayersAfterCooldown();
        }
      });
    });
  }

  Future<void> scheduleScoutAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    await prefs.setInt('lastScoutTime', currentTime);
    setState(() {
      canScout = false;
      _remainingTime = adjustedScoutCooldown;
    });
    startScoutTimer();
  }

  Future<void> generatePlayersAfterCooldown() async {
    List<Player> newPlayers = [];
    for (int i = 0; i < 3; i++) {
      Player player = await Player.generateRandomFootballer(
        nationality: selectedNationality,
        position: selectedPosition,
      );
      newPlayers.add(player);
    }
    setState(() {
      scoutedPlayers = newPlayers;
    });
    await _saveScoutedPlayers();
  }

  Future<void> _saveSelectedPosition(String position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedPosition', position);
  }

  Future<void> _saveSelectedNationality(String nationality) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedNationality', nationality);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
      body: Container(
        color: AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOptionButton(
                    index: 0,
                    text: 'Transfers',
                    onTap: () => _onOptionSelected(0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  _buildOptionButton(
                    index: 1,
                    text: 'Stuff',
                    onTap: () => _onOptionSelected(1),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  _buildOptionButton(
                    index: 2,
                    text: 'Scouting',
                    onTap: () => _onOptionSelected(2),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildTransfersView(screenWidth, screenHeight),
                  _buildStuffView(screenWidth, screenHeight),
                  _buildScoutingView(screenWidth, screenHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required int index,
    required String text,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
  }) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01, horizontal: screenWidth * 0.03),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: AppColors.borderColor,
          ),
          color: isSelected ? AppColors.blueColor : AppColors.buttonColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 6)
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: isSelected
                ? AppColors.textEnabledColor
                : AppColors.textEnabledColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransfersView(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: _players.length,
        itemBuilder: (context, index) {
          return TransfersPlayerWidget(player: _players[index]);
        },
      ),
    );
  }

  Widget _buildStuffView(double screenWidth, double screenHeight) {
    return Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(10.0),
          color: AppColors.hoverColor,
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(screenWidth * 0.04),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.02),
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: AppColors.blueColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Stuff Item ${index + 1}',
                style: const TextStyle(color: AppColors.textEnabledColor),
              ),
            );
          },
        ));
  }

  Widget _buildScoutingView(double screenWidth, double screenHeight) {
    final nationalities = [
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
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.hoverColor,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoutInfo(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.04),
                  const Text(
                    'Select Position',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  PositionSelector(
                    selectedPosition: selectedPosition,
                    canScout: canScout,
                    onPositionChange: (position) {
                      setState(() {
                        selectedPosition = position;
                      });
                      _saveSelectedPosition(position);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  const Text(
                    'Select Nationality',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  NationalitySelector(
                    selectedNationality: selectedNationality,
                    canScout: canScout,
                    onNationalityChange: (nationality) {
                      setState(() {
                        selectedNationality = nationality;
                      });
                      _saveSelectedNationality(nationality);
                    },
                    nationalities: nationalities,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (scoutedPlayers.isNotEmpty)
                    Column(
                      children: scoutedPlayers
                          .map(
                              (player) => TransfersPlayerWidget(player: player))
                          .toList(),
                    ),
                  if (!canScout)
                    Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        LinearProgressIndicator(
                          value: 1 -
                              _remainingTime.inSeconds /
                                  adjustedScoutCooldown.inSeconds,
                          color: AppColors.blueColor,
                          backgroundColor: AppColors.hoverColor,
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Next scout available in: ${formatDuration(_remainingTime)}',
                          style: const TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textEnabledColor,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: screenHeight * 0.02),
                  GestureDetector(
                    onTap: canScout
                        ? () async {
                            setState(() {
                              canScout = false;
                            });
                            await scheduleScoutAvailability();
                          }
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: canScout
                              ? AppColors.textEnabledColor
                              : AppColors.textEnabledColor,
                        ),
                        color:
                            canScout ? AppColors.blueColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: canScout
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 4),
                                  blurRadius: 6,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          'Scout',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: canScout
                                ? AppColors.textEnabledColor
                                : AppColors.textEnabledColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoutInfo(double screenWidth, double screenHeight) {
    final reductionPercentage = scoutingTimeReductionPercentage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scouting',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
              Tooltip(
                waitDuration: const Duration(seconds: 1),
                message: 'Current time reduction: $reductionPercentage%',
                decoration: BoxDecoration(
                  color: AppColors.hoverColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Level $level',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textEnabledColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            GestureDetector(
              onTap: UserManager.money >= upgradeCost ? increaseLevel : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                  horizontal: screenWidth * 0.05,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 1,
                    color: UserManager.money >= upgradeCost
                        ? AppColors.buttonColor
                        : AppColors.textEnabledColor,
                  ),
                  color: UserManager.money >= upgradeCost
                      ? AppColors.blueColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: UserManager.money >= upgradeCost
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: UserManager.money >= upgradeCost
                          ? AppColors.green
                          : AppColors.textEnabledColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Cost: $upgradeCost',
              style: TextStyle(
                color: UserManager.money >= upgradeCost
                    ? AppColors.green
                    : AppColors.textEnabledColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
