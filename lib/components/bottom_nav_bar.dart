import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pocket_eleven/design/colors.dart';

class BottomNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  const BottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: GNav(
          onTabChange: (value) => onTabChange!(value),
          mainAxisAlignment: MainAxisAlignment.center,
          backgroundColor: AppColors.hoverColor,
          tabBackgroundColor: AppColors.disabledColor,
          activeColor: AppColors.textEnabledColor,
          color: AppColors.textDisabledColor,
          gap: 8,
          tabs: const [
            //home tam
            GButton(icon: Icons.stadium, text: 'Stadium'),
            // play tab
            GButton(icon: Icons.play_circle_fill, text: 'Play'),
            //transfer tab
            GButton(icon: Icons.people_alt, text: 'Transfer'),
            //league tab
            GButton(icon: Icons.list_alt, text: 'League'),
          ]),
    );
  }
}
