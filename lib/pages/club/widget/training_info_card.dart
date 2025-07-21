import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/widget/build_info.dart';

/// A reusable card widget that displays training information including level,
/// upgrade cost, and provides upgrade functionality.
///
/// This widget is completely independent and can be used anywhere in the app
/// where training information needs to be displayed.
///
/// Example usage:
/// ```dart
/// TrainingInfoCard(
///   level: 3,
///   upgradeCost: 50000,
///   isUpgradeEnabled: true,
///   isUpgrading: false,
///   headerText: 'Training Center',
///   onUpgradePressed: () => _upgradeTraining(),
/// )
/// ```
class TrainingInfoCard extends StatelessWidget {
  /// Creates a training information card
  const TrainingInfoCard({
    super.key,
    required this.level,
    required this.upgradeCost,
    required this.isUpgradeEnabled,
    required this.isUpgrading,
    required this.headerText,
    required this.onUpgradePressed,
  });

  /// Current training level to display
  final int level;

  /// Cost required to upgrade to next level
  final int upgradeCost;

  /// Whether the upgrade button should be enabled
  final bool isUpgradeEnabled;

  /// Whether upgrade operation is currently in progress
  final bool isUpgrading;

  /// Header text to display (e.g., "Training", "Gym", etc.)
  final String headerText;

  /// Callback function when upgrade button is pressed
  final VoidCallback onUpgradePressed;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: BuildInfo(
          headerText: headerText,
          level: level,
          upgradeCost: upgradeCost,
          isUpgradeEnabled: isUpgradeEnabled,
          onUpgradePressed: onUpgradePressed,
        ),
      ),
    );
  }
}
