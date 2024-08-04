import 'package:flutter/material.dart';
import 'package:pocket_eleven/controller/user_manager.dart';
import 'package:unicons/unicons.dart';

import '../design/colors.dart';

class CustomAppBar extends StatelessWidget {
  final double screenHeight;

  const CustomAppBar({required this.screenHeight});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
                _buildInfoRow(
                    UniconsLine.medkit, UserManager.medicalPoints.toString()),
                _buildInfoRow(
                    UniconsLine.six_plus, UserManager.youthPoints.toString()),
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
}
