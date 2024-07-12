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
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.textEnabledColor),
        backgroundColor: AppColors.hoverColor,
        toolbarHeight: 50,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    const Icon(
                      UniconsLine.no_entry,
                      color: AppColors.textEnabledColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      UserManager.trainingPoints.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textEnabledColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(
                      UniconsLine.medkit,
                      color: AppColors.textEnabledColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      UserManager.medicalPoints.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textEnabledColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(
                      UniconsLine.six_plus,
                      color: AppColors.textEnabledColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      UserManager.youthPoints.toString(),
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textEnabledColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(
                      UniconsLine.usd_circle,
                      color: AppColors.textEnabledColor,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      UserManager.money.toStringAsFixed(0),
                      style: const TextStyle(
                        fontSize: 20,
                        color: AppColors.textEnabledColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _clubStadiumImage.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.primaryColor,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                          const SizedBox(height: 8.0),
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
                  ),
                  const SizedBox(height: 40.0),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    'The club stadium is the heart of our community, where fans gather '
                    'to cheer for their favorite teams. With a capacity of 50,000 seats, '
                    'it has hosted numerous memorable matches and events.',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: AppColors.textEnabledColor,
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
