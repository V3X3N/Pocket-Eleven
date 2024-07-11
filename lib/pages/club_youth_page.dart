import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class ClubYouthPage extends StatefulWidget {
  const ClubYouthPage({super.key});

  @override
  State<ClubYouthPage> createState() => _ClubYouthPageState();
}

class _ClubYouthPageState extends State<ClubYouthPage> {
  late Image _clubStadiumImage;
  int level = 1;

  @override
  void initState() {
    super.initState();
    _clubStadiumImage = Image.asset('assets/background/club_youth.png');
  }

  void increaseLevel() {
    setState(() {
      level++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.hoverColor,
        iconTheme: const IconThemeData(color: AppColors.textEnabledColor),
        title: const Text(
          'Club Youth',
          style: TextStyle(
            fontSize: 20.0,
            color: AppColors.textEnabledColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _clubStadiumImage.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.primaryColor,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Youth Academy',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textEnabledColor,
                            ),
                          ),
                          Text(
                            'Level $level',
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textEnabledColor,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: increaseLevel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryColor,
                        ),
                        child: const Text(
                          'Upgrade',
                          style: TextStyle(
                            color: AppColors.textEnabledColor,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40.0),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  const Text(
                    "Our youth academies are where future football stars develop their skills under the guidance of experienced coaches. "
                    "We provide an inspiring environment for learning and nurturing a passion for soccer, "
                    "shaping not just athletic abilities but also teamwork and determination.",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}