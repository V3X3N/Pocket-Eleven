import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/managers/medical_manager.dart';
import 'package:pocket_eleven/managers/scouting_manager.dart';
import 'package:pocket_eleven/managers/training_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';
import 'package:pocket_eleven/managers/youth_manager.dart';
import 'package:pocket_eleven/pages/transfers/scouting_europe_page.dart';
import 'package:pocket_eleven/pages/transfers/scouting_asia_page.dart';
import 'package:pocket_eleven/pages/transfers/scouting_america_page.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  late Image _europeImage;
  late Image _asiaImage;
  late Image _americaImage;
  int _selectedIndex = 0;

  Future<void> _loadUserData() async {
    try {
      // Assuming UserManager has the relevant methods for loading user data
      await UserManager().loadMoney();
      await TrainingManager().loadTrainingPoints();
      await MedicalManager().loadMedicalPoints();
      await YouthManager().loadYouthPoints();
      // Europe
      await ScoutingManager().loadEuropeScoutingLevel();
      await ScoutingManager().loadEuropeScoutingUpgradeCost();
      // Asia
      await ScoutingManager().loadAsiaScoutingLevel();
      await ScoutingManager().loadAsiaScoutingUpgradeCost();
      // America
      await ScoutingManager().loadAmericaScoutingLevel();
      await ScoutingManager().loadAmericaScoutingUpgradeCost();

      setState(() {});
    } catch (error) {
      debugPrint('Error loading user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _europeImage = Image.asset(
      'assets/background/europe.png',
    );
    _asiaImage = Image.asset(
      'assets/background/asia.png',
    );
    _americaImage = Image.asset(
      'assets/background/north_america.png',
    );
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                  vertical: screenHeight * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _onOptionSelected(0),
                    child: Text(
                      'Transfers',
                      style: TextStyle(
                        fontSize: 18,
                        color: _selectedIndex == 0
                            ? AppColors.secondaryColor
                            : AppColors.textEnabledColor,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  GestureDetector(
                    onTap: () => _onOptionSelected(1),
                    child: Text(
                      'Stuff',
                      style: TextStyle(
                        fontSize: 18,
                        color: _selectedIndex == 1
                            ? AppColors.secondaryColor
                            : AppColors.textEnabledColor,
                      ),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  GestureDetector(
                    onTap: () => _onOptionSelected(2),
                    child: Text(
                      'Scouting',
                      style: TextStyle(
                        fontSize: 18,
                        color: _selectedIndex == 2
                            ? AppColors.secondaryColor
                            : AppColors.textEnabledColor,
                      ),
                    ),
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

  Widget _buildTransfersView(double screenWidth, double screenHeight) {
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: 10, // Example count
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Transfer Item ${index + 1}',
            style: const TextStyle(color: AppColors.textEnabledColor),
          ),
        );
      },
    );
  }

  Widget _buildStuffView(double screenWidth, double screenHeight) {
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: 10, // Example count
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: screenHeight * 0.02),
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Stuff Item ${index + 1}',
            style: const TextStyle(color: AppColors.textEnabledColor),
          ),
        );
      },
    );
  }

  Widget _buildScoutingView(double screenWidth, double screenHeight) {
    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.5,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildListItem(
                screenWidth: screenWidth,
                image: _europeImage,
                text: 'Europe',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoutingEuropePage(
                        onCurrencyChange: () {
                          _loadUserData();
                        },
                      ),
                    ),
                  ).then((_) {
                    _loadUserData();
                  });
                },
              ),
              _buildListItem(
                screenWidth: screenWidth,
                image: _americaImage,
                text: 'America',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoutingAmericaPage(
                        onCurrencyChange: () {
                          _loadUserData();
                        },
                      ),
                    ),
                  ).then((_) {
                    _loadUserData();
                  });
                },
              ),
              _buildListItem(
                screenWidth: screenWidth,
                image: _asiaImage,
                text: 'Asia',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoutingAsiaPage(
                        onCurrencyChange: () {
                          _loadUserData();
                        },
                      ),
                    ),
                  ).then((_) {
                    _loadUserData();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({
    required double screenWidth,
    required Image image,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: screenWidth * 0.5,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: image.image,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: AppColors.textEnabledColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
