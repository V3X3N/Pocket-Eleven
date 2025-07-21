import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'training_attribute_button.dart';

/// A reusable card widget for displaying a player's training interface.
///
/// This widget shows player information and provides training buttons for
/// multiple attributes. It's completely independent and can be used anywhere
/// player training functionality is needed.
///
/// Example usage:
/// ```dart
/// PlayerTrainingCard(
///   playerName: 'John Doe',
///   attributes: [
///     TrainingAttribute(
///       name: 'Speed',
///       value: 75,
///       isTraining: false,
///       onTrain: () => _trainSpeed(),
///     ),
///   ],
///   trainingText: 'Train',
///   trainingInProgressText: 'Training...',
/// )
/// ```
class PlayerTrainingCard extends StatelessWidget {
  /// Creates a player training card
  const PlayerTrainingCard({
    super.key,
    required this.playerName,
    required this.attributes,
    required this.trainingText,
    required this.trainingInProgressText,
  });

  /// Name of the player to display
  final String playerName;

  /// List of training attributes for this player
  final List<TrainingAttribute> attributes;

  /// Text to display on training buttons when not training
  final String trainingText;

  /// Text to display on training buttons when training is in progress
  final String trainingInProgressText;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        return RepaintBoundary(
          child: Container(
            margin: EdgeInsets.only(bottom: screenWidth * 0.02),
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: AppColors.hoverColor,
              border: Border.all(color: AppColors.borderColor),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  playerName,
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textEnabledColor,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),
                Row(
                  children: attributes
                      .map(
                        (attribute) => Expanded(
                          child: TrainingAttributeButton(
                            attributeName: attribute.name,
                            attributeValue: attribute.value,
                            isTraining: attribute.isTraining,
                            trainingText: trainingText,
                            trainingInProgressText: trainingInProgressText,
                            onTrain: attribute.onTrain,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Data class representing a training attribute for a player
class TrainingAttribute {
  /// Creates a training attribute
  const TrainingAttribute({
    required this.name,
    required this.value,
    required this.isTraining,
    required this.onTrain,
  });

  /// Name of the attribute
  final String name;

  /// Current value of the attribute
  final int value;

  /// Whether this attribute is currently being trained
  final bool isTraining;

  /// Callback when training this attribute
  final VoidCallback onTrain;
}
