import 'package:flutter/material.dart';
import 'package:pocket_eleven/databases/database_helper.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayerDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> player;

  const PlayerDetailsDialog({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      backgroundColor: AppColors.hoverColor,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Image and Details
            Row(
              children: [
                // Player Image
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/bust1.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                // Player Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${player[DatabaseHelper.columnFirstName]} ${player[DatabaseHelper.columnLastName]}',
                        style: const TextStyle(color: AppColors.textEnabledColor, fontSize: 18),
                      ),
                      Text(
                        'Position: ${player[DatabaseHelper.columnPosition]}',
                        style: const TextStyle(color: AppColors.textEnabledColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Skills in 3 columns
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 16.0, // Adjust the spacing between skills
                runSpacing: 8.0, // Adjust the spacing between rows
                children: [
                  buildSkillText('Tackling', player[DatabaseHelper.columnTackling]),
                  buildSkillText('Marking', player[DatabaseHelper.columnMarking]),
                  buildSkillText('Positioning', player[DatabaseHelper.columnPositioning]),
                  buildSkillText('Heading', player[DatabaseHelper.columnHeading]),
                  buildSkillText('Passing', player[DatabaseHelper.columnPassing]),
                  buildSkillText('Dribbling', player[DatabaseHelper.columnDribbling]),
                  buildSkillText('Shooting', player[DatabaseHelper.columnShooting]),
                  buildSkillText('Finishing', player[DatabaseHelper.columnFinishing]),
                  buildSkillText('Fitness', player[DatabaseHelper.columnFitness]),
                  buildSkillText('Aggression', player[DatabaseHelper.columnAggression]),
                  buildSkillText('Speed', player[DatabaseHelper.columnSpeed]),
                  buildSkillText('Ball Control', player[DatabaseHelper.columnBallControl]),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: AppColors.textDisabledColor,
            backgroundColor: AppColors.disabledColor,
            disabledForegroundColor: AppColors.textEnabledColor.withOpacity(0.38),
            disabledBackgroundColor: AppColors.textEnabledColor.withOpacity(0.12),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget buildSkillText(String label, dynamic value) {
    return SizedBox(
      width: 120, // Adjust the width as needed
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(color: AppColors.textEnabledColor)),
          Text('$value', style: const TextStyle(color: AppColors.textEnabledColor)),
        ],
      ),
    );
  }
}
