import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class StuffView extends StatelessWidget {
  const StuffView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
        color: AppColors.hoverColor,
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.blueColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Stuff Item ${index + 1}',
              style: const TextStyle(color: AppColors.textEnabledColor),
            ),
          );
        },
      ),
    );
  }
}
