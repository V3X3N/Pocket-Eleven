import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:unicons/unicons.dart';

class PlayerCube extends StatelessWidget {
  final VoidCallback onTap;

  const PlayerCube({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.green,
        child: const Center(
          child: Icon(
            UniconsLine.user,
            color: AppColors.textEnabledColor,
            size: 40,
          ),
        ),
      ),
    );
  }
}
