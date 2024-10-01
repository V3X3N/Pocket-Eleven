import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class FormationView extends StatefulWidget {
  const FormationView({
    super.key,
  });

  @override
  State<FormationView> createState() => _FormationViewState();
}

class _FormationViewState extends State<FormationView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: screenWidth,
      height: screenHeight,
    );
  }
}
