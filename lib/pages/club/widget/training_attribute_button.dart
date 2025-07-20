import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable training button widget for individual player attributes.
///
/// This widget displays an attribute name, its current value, and provides
/// a training button. It's completely independent and can be used for any
/// training-related functionality across the app.
///
/// Example usage:
/// ```dart
/// TrainingAttributeButton(
///   attributeName: 'Speed',
///   attributeValue: 75,
///   isTraining: false,
///   trainingText: 'Train',
///   trainingInProgressText: 'Training...',
///   onTrain: () => _trainAttribute(),
/// )
/// ```
class TrainingAttributeButton extends StatelessWidget {
  /// Creates a training attribute button
  const TrainingAttributeButton({
    super.key,
    required this.attributeName,
    required this.attributeValue,
    required this.isTraining,
    required this.trainingText,
    required this.trainingInProgressText,
    required this.onTrain,
  });

  /// Name of the attribute (e.g., "Speed", "Strength", etc.)
  final String attributeName;

  /// Current value of the attribute
  final int attributeValue;

  /// Whether training is currently in progress for this attribute
  final bool isTraining;

  /// Text to display on button when not training
  final String trainingText;

  /// Text to display on button when training is in progress
  final String trainingInProgressText;

  /// Callback function when train button is pressed
  final VoidCallback onTrain;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$attributeName: $attributeValue',
              style: TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: width * 0.12,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: width * 0.08),
            OptionButton(
              onTap: isTraining ? null : onTrain,
              screenWidth: width,
              screenHeight: width * 1.2,
              text: isTraining ? trainingInProgressText : trainingText,
              fontSizeMultiplier: 0.7,
            ),
          ],
        );
      },
    );
  }
}
