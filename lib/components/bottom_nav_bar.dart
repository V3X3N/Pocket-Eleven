import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pocket_eleven/design/colors.dart';

class BottomNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  final double navBarHeight;
  final double screenWidth;

  const BottomNavBar({
    super.key,
    required this.onTabChange,
    required this.navBarHeight,
    required this.screenWidth,
    required void Function(dynamic newCurrency) onCurrencyChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: navBarHeight,
      width: screenWidth,
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Row(
        children: [
          Expanded(
            child: GNav(
              onTabChange: (value) => onTabChange!(value),
              mainAxisAlignment: MainAxisAlignment.center,
              backgroundColor: AppColors.hoverColor,
              tabBackgroundColor: AppColors.primaryColor,
              activeColor: AppColors.textEnabledColor,
              color: AppColors.textEnabledColor,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: navBarHeight * 0.25,
              ),
              tabs: const [
                //club tab
                GButton(icon: Icons.stadium, text: 'Club'),
                //play tab
                GButton(icon: Icons.play_circle_fill, text: 'Play'),
                //transfer tab
                GButton(icon: Icons.people_alt, text: 'Transfer'),
                //tactic tab
                GButton(icon: Icons.list_alt, text: 'Tactic'),
                //profile tab
                GButton(icon: Icons.account_circle_rounded, text: "Profile")
              ],
            ),
          ),
        ],
      ),
    );
  }
}
