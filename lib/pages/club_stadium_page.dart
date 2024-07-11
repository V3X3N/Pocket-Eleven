import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class ClubStadiumPage extends StatefulWidget {
  const ClubStadiumPage({super.key});

  @override
  State<ClubStadiumPage> createState() => _ClubStadiumPageState();
}

class _ClubStadiumPageState extends State<ClubStadiumPage> {
  late Image _clubStadiumImage;

  @override
  void initState() {
    super.initState();
    _clubStadiumImage = Image.asset('assets/background/club_stadion.png');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.hoverColor,
        title: const Text('Club Stadium'),
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Stadium',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textEnabledColor,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
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
                  const SizedBox(height: 16.0),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'The club stadium is the heart of our community, where fans gather '
                    'to cheer for their favorite teams. With a capacity of 50,000 seats, '
                    'it has hosted numerous memorable matches and events.',
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
