import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pocket_eleven/design/colors.dart';

class BottomNavBar extends StatelessWidget {
  final void Function(int)? onTabChange;
  final double navBarHeight;
  const BottomNavBar(
      {super.key, required this.onTabChange, required this.navBarHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: navBarHeight,
      width: MediaQuery.sizeOf(context).width,
      padding: const EdgeInsets.only(bottom: 0.0),
      child: Row(
        children: [
          Expanded(
            child: GNav(
                onTabChange: (value) => onTabChange!(value),
                mainAxisAlignment: MainAxisAlignment.center,
                backgroundColor: AppColors.hoverColor,
                tabBackgroundColor: AppColors.primaryColor,
                activeColor: AppColors.textEnabledColor,
                color: AppColors.textDisabledColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                ]),
          ),
        ],
      ),
    );
  }
}
