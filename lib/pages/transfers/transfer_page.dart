import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/list_item.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/managers/medical_manager.dart';
import 'package:pocket_eleven/managers/scouting_manager.dart';
import 'package:pocket_eleven/managers/training_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';
import 'package:pocket_eleven/managers/youth_manager.dart';
import 'package:pocket_eleven/pages/transfers/scouting_europe_page.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_widget.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  late Image _europeImage;
  int _selectedIndex = 0;
  List<Player> _players = [];

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
    _loadUserData();
    _generatePlayers();
    _europeImage = Image.asset('assets/background/europe.png');
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
            color: AppColors.enabledColor,
          ),
          color: isSelected ? AppColors.secondaryColor : Colors.transparent,
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
                : AppColors.textDisabledColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTransfersView(double screenWidth, double screenHeight) {
    return ListView.builder(
      padding: EdgeInsets.all(screenWidth * 0.04),
      itemCount: _players.length,
      itemBuilder: (context, index) {
        return TransfersPlayerWidget(player: _players[index]);
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
              ListItem(
                screenWidth: screenWidth,
                image: _europeImage,
                text: 'Europe',
                page: ScoutingEuropePage(onCurrencyChange: _loadUserData),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
