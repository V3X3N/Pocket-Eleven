import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pocket_eleven/design/colors.dart';

class BottomNavBar extends StatelessWidget {
  static const _kTabData = [
    (Icons.stadium_rounded, 'Club'),
    (Icons.play_circle_fill_rounded, 'Play'),
    (Icons.people_alt_rounded, 'Transfer'),
    (Icons.list_alt_rounded, 'Tactic'),
    (Icons.account_circle_rounded, 'Profile'),
  ];

  static const _kAnimationDuration = Duration(milliseconds: 250);
  static const _kBlurSigma = 12.0;
  static const _kBorderRadius = 20.0;
  static const _kIconSize = 24.0;
  static const _kVerticalPadding = 12.0;
  static const _kHorizontalRatio = 0.03;

  final ValueChanged<int>? onTabChange;
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.onTabChange,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final safeBottom = mq.padding.bottom;

    return RepaintBoundary(
      child: Container(
        decoration: _buildDecoration(),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(_kBorderRadius)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _kBlurSigma, sigmaY: _kBlurSigma),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                width * _kHorizontalRatio,
                _kVerticalPadding,
                width * _kHorizontalRatio,
                safeBottom + 8,
              ),
              child: _buildNavBar(width),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(double width) => GNav(
        selectedIndex: selectedIndex,
        onTabChange: onTabChange,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        backgroundColor: Colors.transparent,
        tabBackgroundGradient: _buildTabGradient(),
        activeColor: AppColors.textEnabledColor,
        color: AppColors.textEnabledColor.withValues(alpha: 0.65),
        gap: 8,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.028,
          vertical: 11,
        ),
        tabMargin: const EdgeInsets.symmetric(horizontal: 3),
        tabBorderRadius: 18,
        duration: _kAnimationDuration,
        curve: Curves.easeOutQuart,
        iconSize: _kIconSize,
        textStyle: TextStyle(
          fontSize: width * 0.033,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: AppColors.textEnabledColor,
        ),
        tabs: _kTabData
            .map((data) => GButton(icon: data.$1, text: data.$2))
            .toList(),
      );

  BoxDecoration _buildDecoration() => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.hoverColor.withValues(alpha: 0.95),
            AppColors.hoverColor.withValues(alpha: 0.8),
            AppColors.hoverColor.withValues(alpha: 0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(_kBorderRadius)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            offset: const Offset(0, -6),
            blurRadius: 20,
            spreadRadius: -4,
          ),
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: -1,
          ),
        ],
      );

  LinearGradient _buildTabGradient() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryColor.withValues(alpha: 0.95),
          AppColors.primaryColor.withValues(alpha: 0.75),
          AppColors.primaryColor.withValues(alpha: 0.85),
        ],
        stops: const [0.0, 0.6, 1.0],
      );
}
