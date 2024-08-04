import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class ListItem extends StatelessWidget {
  final double screenWidth;
  final Image image;
  final String text;
  final Widget page;

  const ListItem({
    super.key,
    required this.screenWidth,
    required this.image,
    required this.text,
    required this.page,
  });

  void _navigateToPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      // Optional: you might want to call some callback here if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToPage(context),
      child: Container(
        width: screenWidth * 0.5,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: image.image,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: AppColors.textEnabledColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
