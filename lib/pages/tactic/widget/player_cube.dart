import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:unicons/unicons.dart';

class PlayerCube extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const PlayerCube({super.key, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.green,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              UniconsLine.user,
              color: AppColors.textEnabledColor,
              size: 40,
            ),
            const SizedBox(height: 8.0),
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
