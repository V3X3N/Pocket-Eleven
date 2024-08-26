import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:unicons/unicons.dart';
import 'package:pocket_eleven/design/colors.dart';

class ReusableAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double appBarHeight;

  const ReusableAppBar({
    super.key,
    required this.appBarHeight,
  });

  @override
  State<ReusableAppBar> createState() => _ReusableAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

class _ReusableAppBarState extends State<ReusableAppBar> {
  int stadiumPoints = 0;
  int trainingPoints = 0;
  int medicalPoints = 0;
  int youthPoints = 0;
  double money = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Map<String, dynamic> userData = await FirebaseFunctions.getUserData();
      if (mounted) {
        setState(() {
          stadiumPoints = userData['stadiumPoints'] ?? 0;
          trainingPoints = userData['trainingPoints'] ?? 0;
          medicalPoints = userData['medicalPoints'] ?? 0;
          youthPoints = userData['youthPoints'] ?? 0;
          money = (userData['money'] ?? 0).toDouble();
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
                _buildInfoRow(UniconsLine.no_entry, stadiumPoints.toString()),
                _buildInfoRow(UniconsLine.dumbbell, trainingPoints.toString()),
                _buildInfoRow(UniconsLine.medkit, medicalPoints.toString()),
                _buildInfoRow(UniconsLine.sixteen_plus, youthPoints.toString()),
                _buildInfoRow(UniconsLine.usd_circle, money.toStringAsFixed(0)),
              ],
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
}
