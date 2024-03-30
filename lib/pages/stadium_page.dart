import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class StadiumPage extends StatefulWidget {
  const StadiumPage({super.key});

  @override
  State<StadiumPage> createState() => _StadiumPageState();
}

class _StadiumPageState extends State<StadiumPage> {
  bool _isLoading = true;
  late Image _stadiumImage;

  @override
  void initState() {
    super.initState();
    _loadStadiumImage();
  }

  void _loadStadiumImage() {
    _stadiumImage = Image.asset('assets/background/stadium_bg.png');

    _stadiumImage.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((_, __) {
        setState(() {
          _isLoading = false;
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.hoverColor,
        toolbarHeight: 1,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _stadiumImage.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }
}
