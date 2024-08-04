import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/managers/scouting_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';
import 'package:pocket_eleven/pages/transfers/widgets/nationality_selector.dart';
import 'package:pocket_eleven/pages/transfers/widgets/player_card.dart';
import 'package:pocket_eleven/pages/transfers/widgets/position_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_eleven/controller/player.dart';

class ScoutingEuropePage extends StatefulWidget {
  final VoidCallback onCurrencyChange;

  const ScoutingEuropePage({super.key, required this.onCurrencyChange});

  @override
  State<ScoutingEuropePage> createState() => _ScoutingEuropePageState();
}

class _ScoutingEuropePageState extends State<ScoutingEuropePage> {
  late Image _europeImage;
  int level = 1;
  int upgradeCost = 200000;
  String selectedPosition = 'LW';
  String selectedNationality = 'AUT';
  bool canScout = true;
  Timer? _timer;
  Duration _remainingTime = const Duration(minutes: 1);
  final Duration _scoutCooldown = const Duration(minutes: 1);
  List<Player> scoutedPlayers = [];

  @override
  void initState() {
    super.initState();
    _europeImage = Image.asset('assets/background/europe.png');
    level = ScoutingManager.europeScoutingLevel;
    upgradeCost = ScoutingManager.europeScoutingUpgradeCost;
  }

  void increaseLevel() {
    if (UserManager.money >= upgradeCost) {
      setState(() {
        level++;
        UserManager.money -= upgradeCost;
        ScoutingManager.europeScoutingLevel = level;
        ScoutingManager.europeScoutingUpgradeCost =
            ((upgradeCost * 1.8) / 10000).round() * 10000;
        upgradeCost = ScoutingManager.europeScoutingUpgradeCost;
      });

      widget.onCurrencyChange();

      ScoutingManager().saveEuropeScoutingLevel();
      ScoutingManager().saveEuropeScoutingUpgradeCost();
    }
  }

  Future<void> checkScoutAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScoutTime = prefs.getInt('lastScoutTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final diff = currentTime - lastScoutTime;

    if (diff < _scoutCooldown.inMilliseconds) {
      setState(() {
        canScout = false;
        _remainingTime =
            Duration(milliseconds: _scoutCooldown.inMilliseconds - diff);
      });
      startScoutTimer();
    }
  }

  void startScoutTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          canScout = true;
          _timer?.cancel();
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
      _remainingTime = _scoutCooldown;
    });
    startScoutTimer();
  }

  Future<void> generatePlayersAfterCooldown() async {
    // Wait until cooldown is finished
    await Future.delayed(_scoutCooldown);

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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final nationalities = [
      'AUT',
      'BEL',
      'ENG',
      'ESP',
      'FRA',
      'GER',
      'ITA',
      'POL',
      'TUR'
    ];

    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _europeImage.image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
              color: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEuropeScoutInfo(),
                  SizedBox(height: screenHeight * 0.06),
                  const Text(
                    'Select Position',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  PositionSelector(
                    selectedPosition: selectedPosition,
                    canScout: canScout,
                    onPositionChange: (position) {
                      setState(() {
                        selectedPosition = position;
                      });
                    },
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  const Text(
                    'Select Nationality',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  NationalitySelector(
                    selectedNationality: selectedNationality,
                    canScout: canScout,
                    onNationalityChange: (nationality) {
                      setState(() {
                        selectedNationality = nationality;
                      });
                    },
                    nationalities: nationalities,
                  ),
                  SizedBox(height: screenHeight * 0.06),
                  if (!canScout)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: 1 -
                              _remainingTime.inSeconds /
                                  _scoutCooldown.inSeconds,
                          color: AppColors.secondaryColor,
                          backgroundColor: AppColors.hoverColor,
                        ),
                        SizedBox(height: screenHeight * 0.01),
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
                  SizedBox(height: screenHeight * 0.04),
                  Center(
                    child: ElevatedButton(
                      onPressed: canScout
                          ? () async {
                              setState(() {
                                canScout = false;
                              });
                              await scheduleScoutAvailability();
                              await generatePlayersAfterCooldown(); // Generate players after cooldown
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondaryColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.2,
                          vertical: screenHeight * 0.02,
                        ),
                      ),
                      child: const Text(
                        'Scout',
                        style: TextStyle(
                          color: AppColors.textEnabledColor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (scoutedPlayers.isNotEmpty)
                    ...scoutedPlayers
                        .map((player) => PlayerCard(player: player)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEuropeScoutInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Europe Scouting',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
              Text(
                'Level $level',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            ElevatedButton(
              onPressed:
                  UserManager.money >= upgradeCost ? increaseLevel : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Cost: $upgradeCost',
              style: TextStyle(
                color: UserManager.money >= upgradeCost
                    ? AppColors.green
                    : Colors.grey,
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
