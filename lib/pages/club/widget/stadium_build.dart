import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_confirm_dialog.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_painter.dart';

class StadiumBuild extends StatefulWidget {
  const StadiumBuild({super.key});

  @override
  _StadiumBuildState createState() => _StadiumBuildState();
}

class _StadiumBuildState extends State<StadiumBuild> {
  Map<String, int>? sectorLevel;
  int stadiumLevel = 0;
  double userMoney = 0;

  @override
  void initState() {
    super.initState();
    _getStadiumData();
  }

  Future<void> _getStadiumData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDocRef = firestore.collection('users').doc(userId);

      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey('sectorLevel')) {
          setState(() {
            sectorLevel = Map<String, int>.from(userData['sectorLevel']);
          });
        }

        if (userData.containsKey('stadiumLevel')) {
          setState(() {
            stadiumLevel = userData['stadiumLevel'];
          });
          debugPrint('Stadium level fetched: $stadiumLevel');
        }

        if (userData.containsKey('money')) {
          setState(() {
            userMoney = userData['money'].toDouble();
          });
        }
      } else {
        debugPrint('User document not found.');
      }
    } catch (e) {
      debugPrint('Error fetching stadium data: $e');
    }
  }

  Future<void> _updateSectorLevel(int index) async {
    String sectorKey = 'sector$index';

    if (sectorLevel == null || stadiumLevel == 0) {
      debugPrint('Sector or stadium data not loaded.');
      return;
    }

    int currentLevel = sectorLevel?[sectorKey] ?? 0;

    if (currentLevel >= stadiumLevel) {
      debugPrint(
          'Cannot upgrade. Sector $index level ($currentLevel) has reached stadium level ($stadiumLevel).');
      _showSnackBar('Sector level cannot exceed the stadium level.');
      return;
    }

    // Calculate the cost of upgrading the sector
    int upgradeCost = 75000 * (currentLevel + 1) + 75000;

    // Check if the user has enough money
    if (userMoney < upgradeCost) {
      _showSnackBar('Not enough money to upgrade sector $index.');
      return;
    }

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userDocRef = firestore.collection('users').doc(userId);

      await firestore.runTransaction((transaction) async {
        DocumentSnapshot userDoc = await transaction.get(userDocRef);
        if (!userDoc.exists) throw Exception("User document does not exist!");

        int newLevel = currentLevel + 1;
        transaction.update(userDocRef, {
          'sectorLevel.$sectorKey': newLevel,
          'money': userMoney - upgradeCost, // Deduct the upgrade cost
        });

        debugPrint('Sector $index upgraded to level $newLevel');
      });

      await _getStadiumData();
    } catch (e) {
      debugPrint('Error updating sector $index: $e');
    }
  }

  void _onRectangleTapped(int index) async {
    String sectorKey = 'sector$index';
    int currentLevel = sectorLevel?[sectorKey] ?? 0;

    debugPrint('Sector $index clicked. Level from Firestore: $currentLevel');

    // Calculate the upgrade cost for this sector
    int upgradeCost = 75000 * (currentLevel + 1) + 75000;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StadiumConfirmDialog(
          title: 'Upgrade Sector $index',
          message:
              'Current Level: $currentLevel\nUpgrade Cost: \$${upgradeCost.toString()}.\nDo you want to upgrade?',
          onConfirm: () async {
            await _updateSectorLevel(index);
          },
          onCancel: () {
            debugPrint('Upgrade cancelled for sector $index');
          },
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildInteractiveRectangle({
    required Color color,
    required int index,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: () => _onRectangleTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: index == 5 ? Colors.white : AppColors.borderColor,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
        child: index == 5
            ? CustomPaint(
                painter: LinePainter(width: width, height: height),
                child: Container(),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridSize = screenWidth * 1.0;
    final double smallSquareWidth = gridSize / 8;
    final double smallSquareHeight = smallSquareWidth;
    final double centerSquareWidth = smallSquareWidth * 4;
    final double centerSquareHeight = centerSquareWidth;
    final double reducedCenterSquareWidth = centerSquareWidth * (2 / 3);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              spreadRadius: 4.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 1,
                  width: smallSquareWidth,
                  height: smallSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 2,
                  width: reducedCenterSquareWidth,
                  height: smallSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 3,
                  width: smallSquareWidth,
                  height: smallSquareHeight,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 4,
                  width: smallSquareWidth,
                  height: centerSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: Colors.lightGreen.shade400,
                  index: 5,
                  width: reducedCenterSquareWidth,
                  height: centerSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 6,
                  width: smallSquareWidth,
                  height: centerSquareHeight,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 7,
                  width: smallSquareWidth,
                  height: smallSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 8,
                  width: reducedCenterSquareWidth,
                  height: smallSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 9,
                  width: smallSquareWidth,
                  height: smallSquareHeight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
