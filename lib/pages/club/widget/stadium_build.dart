import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class StadiumBuild extends StatelessWidget {
  const StadiumBuild({super.key});

  void _onRectangleTapped(int index) {
    debugPrint('Sector $index clicked.');
  }

  Widget _buildInteractiveRectangle({
    required Color color,
    required int index,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: () => _onRectangleTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: AppColors.borderColor,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.0,
              spreadRadius: 2.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double gridSize = screenWidth * 1.0;
    final double smallSquareWidth = gridSize / 8;
    final double smallSquareHeight = smallSquareWidth;
    final double centerSquareWidth = smallSquareWidth * 4;
    final double centerSquareHeight = centerSquareWidth;
    final double reducedCenterSquareWidth = centerSquareWidth * (2 / 3);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: AppColors.borderColor,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              spreadRadius: 4.0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 1,
                  width: smallSquareWidth,
                  height: smallSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 2,
                  width: reducedCenterSquareWidth,
                  height: smallSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 3,
                  width: smallSquareWidth,
                  height: smallSquareHeight,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 4,
                  width: smallSquareWidth,
                  height: centerSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 5,
                  width: reducedCenterSquareWidth,
                  height: centerSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 6,
                  width: smallSquareWidth,
                  height: centerSquareHeight,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 7,
                  width: smallSquareWidth,
                  height: smallSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 8,
                  width: reducedCenterSquareWidth,
                  height: smallSquareHeight,
                ),
                const SizedBox(width: 10),
                _buildInteractiveRectangle(
                  color: AppColors.buttonColor,
                  index: 9,
                  width: smallSquareWidth,
                  height: smallSquareHeight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
