import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable header widget for standings table
///
/// Features:
/// - Responsive column widths
/// - Consistent styling
/// - Customizable column headers
/// - Optimized for performance
class StandingsHeader extends StatelessWidget {
  /// Creates a standings header
  ///
  /// [headers] - Map of column headers with their respective flex values
  /// [backgroundColor] - Background color for the header
  /// [textColor] - Text color for header labels
  const StandingsHeader({
    required this.headers,
    this.backgroundColor,
    this.textColor = AppColors.textEnabledColor,
    super.key,
  });

  final Map<String, int> headers;
  final Color? backgroundColor;
  final Color textColor;

  static const Map<String, int> defaultHeaders = {
    'Team': 3,
    'MP': 1,
    'GF': 1,
    'GA': 1,
    'GD': 1,
    'Pts': 1,
  };

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color:
            backgroundColor ?? AppColors.primaryColor.withValues(alpha: 0.15),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(width: screenWidth * 0.08), // Position space
          ...headers.entries.map((entry) => Expanded(
                flex: entry.value,
                child: _HeaderCell(
                  text: entry.key,
                  textColor: textColor,
                ),
              )),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.text,
    required this.textColor,
  });

  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: screenWidth * 0.035,
        ),
      ),
    );
  }
}
