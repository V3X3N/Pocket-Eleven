import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/user_manager.dart';
import 'package:unicons/unicons.dart';

class ClubStadiumPage extends StatefulWidget {
  final VoidCallback onCurrencyChange;

  const ClubStadiumPage({super.key, required this.onCurrencyChange});

  @override
  State<ClubStadiumPage> createState() => _ClubStadiumPageState();
}

class _ClubStadiumPageState extends State<ClubStadiumPage> {
  late Image _clubStadiumImage;
  int level = 1;
  int stadiumUpgradeCost = 100000;

  @override
  void initState() {
    super.initState();
    _clubStadiumImage = Image.asset('assets/background/club_stadion.png');
    level = UserManager.stadiumLevel;
    stadiumUpgradeCost = UserManager.stadiumUpgradeCost;
  }

  void increaseLevel() {
    if (UserManager.money >= stadiumUpgradeCost) {
      setState(() {
        level++;
        UserManager.money -= stadiumUpgradeCost;
        UserManager.stadiumLevel = level;
        UserManager.stadiumUpgradeCost =
            ((stadiumUpgradeCost * 1.8) / 10000).round() * 10000;
        stadiumUpgradeCost = UserManager.stadiumUpgradeCost;
      });

      widget.onCurrencyChange();

      UserManager().saveStadiumLevel();
      UserManager().saveStadiumUpgradeCost();
    }
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
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _clubStadiumImage.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStadiumInfo(),
                  SizedBox(height: screenHeight * 0.04),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Expanded(
                    child: SingleChildScrollView(
                      child: const Text(
                        'The club stadium is the heart of our community, where fans gather '
                        'to cheer for their favorite teams. With a capacity of 50,000 seats, '
                        'it has hosted numerous memorable matches and events.',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: AppColors.textEnabledColor,
                        ),
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

  Widget _buildStadiumInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stadium',
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
              onPressed: UserManager.money >= stadiumUpgradeCost
                  ? increaseLevel
                  : null,
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
            SizedBox(height: 8.0),
            Text(
              'Cost: $stadiumUpgradeCost',
              style: TextStyle(
                color: UserManager.money >= stadiumUpgradeCost
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
