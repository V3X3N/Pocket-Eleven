import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/user_manager.dart';
import 'package:unicons/unicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  Duration _remainingTime = const Duration(hours: 8);

  @override
  void initState() {
    super.initState();
    _europeImage = Image.asset('assets/background/europe.png');
    level = UserManager.europeScoutingLevel;
    upgradeCost = UserManager.europeScoutingUpgradeCost;
    checkScoutAvailability();
  }

  void increaseLevel() {
    if (UserManager.money >= upgradeCost) {
      setState(() {
        level++;
        UserManager.money -= upgradeCost;
        UserManager.trainingLevel = level;
        UserManager.trainingUpgradeCost =
            ((upgradeCost * 1.8) / 10000).round() * 10000;
        upgradeCost = UserManager.trainingUpgradeCost;
      });

      widget.onCurrencyChange();

      UserManager().saveTrainingLevel();
      UserManager().saveTrainingUpgradeCost();
    }
  }

  Future<void> checkScoutAvailability() async {
    final prefs = await SharedPreferences.getInstance();
    final lastScoutTime = prefs.getInt('lastScoutTime') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final diff = currentTime - lastScoutTime;

    if (diff < 8 * 60 * 60 * 1000) {
      setState(() {
        canScout = false;
        _remainingTime = Duration(milliseconds: 8 * 60 * 60 * 1000 - diff);
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
      _remainingTime = const Duration(hours: 8);
    });
    startScoutTimer();
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
    final double appBarHeight = screenHeight * 0.07;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: AppBar(
          iconTheme: const IconThemeData(color: AppColors.textEnabledColor),
          backgroundColor: AppColors.hoverColor,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoRow(UniconsLine.no_entry,
                        UserManager.trainingPoints.toString()),
                    _buildInfoRow(UniconsLine.medkit,
                        UserManager.medicalPoints.toString()),
                    _buildInfoRow(UniconsLine.six_plus,
                        UserManager.youthPoints.toString()),
                    _buildInfoRow(UniconsLine.usd_circle,
                        UserManager.money.toStringAsFixed(0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                  _buildPositionSelector(),
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
                  _buildNationalitySelector(),
                  SizedBox(height: screenHeight * 0.06),
                  if (!canScout)
                    Column(
                      children: [
                        LinearProgressIndicator(
                          value: 1 - _remainingTime.inSeconds / (8 * 60 * 60),
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
                      onPressed: canScout ? () {
                        setState(() {
                          canScout = false;
                        });
                        scheduleScoutAvailability();
                        // Add your scout functionality here
                      } : null,
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
                  if (screenHeight > 600) // Condition to check screen height and add more widgets if there's extra space
                    ...[
                      SizedBox(height: screenHeight * 0.05),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textEnabledColor),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.textEnabledColor,
          ),
        ),
      ],
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

  Widget _buildPositionSelector() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
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
        ].map((position) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedPosition = position;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: selectedPosition == position
                    ? AppColors.secondaryColor
                    : AppColors.hoverColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  position,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textEnabledColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNationalitySelector() {
    final nationalities = [
      'AUT',
      'BEL',
      'ENG',
      'FRA',
      'GER',
      'ITA',
      'POL',
      'ESP',
      'TUR'
    ];

    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: nationalities.map((countryCode) {
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedNationality = countryCode;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: selectedNationality == countryCode
                    ? AppColors.secondaryColor
                    : AppColors.hoverColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Image.asset('assets/flags/flag_$countryCode.png',
                    width: 30, height: 20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
