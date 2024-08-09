import 'package:flutter/material.dart';
import 'package:pocket_eleven/managers/medical_manager.dart';
import 'package:pocket_eleven/managers/training_manager.dart';
import 'package:pocket_eleven/managers/user_manager.dart';
import 'package:pocket_eleven/managers/youth_manager.dart';
import 'package:unicons/unicons.dart';
import 'package:pocket_eleven/design/colors.dart';

class ReusableAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double appBarHeight;

  const ReusableAppBar({
    super.key,
    required this.appBarHeight,
  });

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
                _buildInfoRow(UniconsLine.no_entry,
                    TrainingManager.trainingPoints.toString()),
                _buildInfoRow(UniconsLine.medkit,
                    MedicalManager.medicalPoints.toString()),
                _buildInfoRow(
                    UniconsLine.six_plus, YouthManager.youthPoints.toString()),
                _buildInfoRow(UniconsLine.usd_circle,
                    UserManager.money.toStringAsFixed(0)),
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

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}
