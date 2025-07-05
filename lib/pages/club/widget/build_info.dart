import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';

class BuildInfo extends StatelessWidget {
  static const double _headerFontSize = 24.0;
  static const double _levelFontSize = 16.0;
  static const double _costFontSize = 16.0;
  static const double _iconSize = 16.0;
  static const double _spacing = 8.0;
  static const double _smallSpacing = 4.0;
  static const int _baseCost = 10000;
  static const int _costReduction = 500;

  final String headerText;
  final int level;
  final int upgradeCost;
  final bool isUpgradeEnabled;
  final VoidCallback? onUpgradePressed;

  const BuildInfo({
    super.key,
    required this.headerText,
    required this.level,
    required this.upgradeCost,
    required this.isUpgradeEnabled,
    this.onUpgradePressed,
  });

  // Precompute training cost to avoid calculation in build
  int get _trainingCost => _baseCost - ((level - 1) * _costReduction);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: _HeaderSection(
            headerText: headerText,
            level: level,
            trainingCost: _trainingCost,
          ),
        ),
        _UpgradeSection(
          upgradeCost: upgradeCost,
          isUpgradeEnabled: isUpgradeEnabled,
          onUpgradePressed: onUpgradePressed,
          screenWidth: size.width,
          screenHeight: size.height,
        ),
      ],
    );
  }
}

// Extract header section to prevent unnecessary rebuilds
class _HeaderSection extends StatelessWidget {
  static const TextStyle _headerStyle = TextStyle(
    fontSize: BuildInfo._headerFontSize,
    fontWeight: FontWeight.bold,
    color: AppColors.textEnabledColor,
  );

  static const TextStyle _levelStyle = TextStyle(
    fontSize: BuildInfo._levelFontSize,
    fontWeight: FontWeight.bold,
    color: AppColors.textEnabledColor,
  );

  static const BoxDecoration _tooltipDecoration = BoxDecoration(
    color: AppColors.hoverColor,
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  );

  static const Icon _infoIcon = Icon(
    Icons.info_outline,
    color: AppColors.textEnabledColor,
    size: BuildInfo._iconSize,
  );

  final String headerText;
  final int level;
  final int trainingCost;

  const _HeaderSection({
    required this.headerText,
    required this.level,
    required this.trainingCost,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headerText,
            style: _headerStyle,
          ),
          Tooltip(
            triggerMode: TooltipTriggerMode.tap,
            message: 'Current training cost: $trainingCost',
            decoration: _tooltipDecoration,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level $level',
                  style: _levelStyle,
                ),
                const SizedBox(width: BuildInfo._smallSpacing),
                _infoIcon,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Extract upgrade section to isolate expensive operations
class _UpgradeSection extends StatelessWidget {
  static const TextStyle _costStyle = TextStyle(
    color: AppColors.textEnabledColor,
    fontSize: BuildInfo._costFontSize,
    fontWeight: FontWeight.bold,
  );

  final int upgradeCost;
  final bool isUpgradeEnabled;
  final VoidCallback? onUpgradePressed;
  final double screenWidth;
  final double screenHeight;

  const _UpgradeSection({
    required this.upgradeCost,
    required this.isUpgradeEnabled,
    required this.onUpgradePressed,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OptionButton(
            onTap: isUpgradeEnabled ? onUpgradePressed : null,
            text: "Upgrade",
            screenWidth: screenWidth,
            screenHeight: screenHeight,
          ),
          const SizedBox(height: BuildInfo._spacing),
          Text(
            'Cost: $upgradeCost',
            style: _costStyle,
          ),
        ],
      ),
    );
  }
}
