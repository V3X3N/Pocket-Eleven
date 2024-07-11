import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class ClubMedicalPage extends StatefulWidget {
  const ClubMedicalPage({super.key});

  @override
  State<ClubMedicalPage> createState() => _ClubMedicalPageState();
}

class _ClubMedicalPageState extends State<ClubMedicalPage> {
  late Image _clubStadiumImage;
  int level = 1;

  @override
  void initState() {
    super.initState();
    _clubStadiumImage = Image.asset('assets/background/club_medical.png');
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
          'Club Medical',
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
                            'Medical Center',
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
                    "Our medical center is an essential part of our commitment to our players' health and fitness. "
                    "With a team of experienced doctors and therapists, we offer comprehensive medical care, "
                    "ensuring optimal conditions for rehabilitation and swift recovery from injuries. "
                    "It’s a place where we prioritize every aspect of our athletes' health, providing safety and support throughout their careers.",
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
