import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  List<String> footballers = [
    'Cristiano',
    'Lionel',
    'Neymar',
    'Kylian',
    'Mohamed',
    'Robert',
    'Sergio',
    'Kevin',
    'Luka',
    'Karim',
    'Eden',
    'Sadio',
    'Virgil',
    'Paulo',
    'Harry',
    'Raheem',
    'N\'Golo',
    'Manuel',
    'Jan',
    'Thiago',
  ];

  List<String> positions = [
    'GK',
    'DL',
    'DC',
    'DR',
    'ML',
    'MC',
    'MR',
    'RW',
    'ST',
    'LW',
  ];

  List<Player> selectedFootballers = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedFootballers();
  }

  Future<void> _loadSelectedFootballers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? footballersJson = prefs.getString('selectedFootballers');
    if (footballersJson != null) {
      setState(() {
        Iterable list = jsonDecode(footballersJson);
        selectedFootballers =
            list.map((model) => Player.fromJson(model)).toList();
      });
    }
  }

  Future<void> _generateRandomFootballers() async {
    final random = Random();
    List<Player> tempList = [];
    List<String> nationalities = [
      'AUT',
      'BEL',
      'BRA',
      'ENG',
      'FRA',
      'GER',
      'ITA',
      'JPN',
      'POL',
      'ESP',
      'USA',
      'TUR'
    ];
    for (int i = 0; i < 6; i++) {
      int randomIndex = random.nextInt(footballers.length);
      String selectedFootballer = footballers[randomIndex];
      String position = positions[random.nextInt(positions.length)];
      int ovr = random.nextInt(230) + 21;
      int age = random.nextInt(14) + 18;
      String nationality = nationalities[random.nextInt(nationalities.length)];
      String imagePath = _getImagePath(ovr);
      String flagPath = 'assets/flags/flag_$nationality.png';
      tempList.add(Player(
          name: selectedFootballer,
          position: position,
          ovr: ovr,
          age: age,
          nationality: nationality,
          imagePath: imagePath,
          flagPath: flagPath));
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFootballers', jsonEncode(tempList));
    setState(() {
      selectedFootballers = tempList;
    });
  }

  String _getImagePath(int ovr) {
    if (ovr >= 201) {
      return 'assets/players/player_card_purple.png';
    } else if (ovr >= 151 && ovr < 200) {
      return 'assets/players/player_card_gold.png';
    } else if (ovr >= 101 && ovr < 150) {
      return 'assets/players/player_card_silver.png';
    } else {
      return 'assets/players/player_card_bronze.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView.builder(
                itemCount: selectedFootballers.length,
                itemBuilder: (context, index) {
                  Player player = selectedFootballers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.hoverColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              player.imagePath,
                              width: 64,
                              height: 64,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${player.name} (${player.position})',
                                  style: const TextStyle(
                                    color: AppColors.textEnabledColor,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Badge: ${player.badge}',
                                  style: const TextStyle(
                                    color: AppColors.textEnabledColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Age: ${player.age}',
                                  style: const TextStyle(
                                    color: AppColors.textEnabledColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            children: [
                              Image.asset(
                                player.flagPath,
                                width: 32,
                                height: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${player.ovr}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppColors.textEnabledColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            height: 80,
            child: MaterialButton(
              onPressed: () {
                _generateRandomFootballers();
              },
              padding: const EdgeInsets.all(16.0),
              color: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Center(
                child: Text(
                  'DRAW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}

class Player {
  final String name;
  final String position;
  final int ovr;
  final int age;
  final String nationality;
  final String imagePath;
  final String flagPath;
  late final String badge;

  Player(
      {required this.name,
      required this.position,
      required this.ovr,
      required this.age,
      required this.nationality,
      required this.imagePath,
      required this.flagPath}) {
    badge = _calculateBadge();
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      position: json['position'],
      ovr: json['ovr'],
      age: json['age'],
      nationality: json['nationality'],
      imagePath: json['imagePath'],
      flagPath: json['flagPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'ovr': ovr,
      'age': age,
      'nationality': nationality,
      'imagePath': imagePath,
      'flagPath': flagPath,
    };
  }

  String _calculateBadge() {
    if (ovr >= 201) {
      return 'purple';
    } else if (ovr >= 151 && ovr < 200) {
      return 'gold';
    } else if (ovr >= 101 && ovr < 150) {
      return 'silver';
    } else {
      return 'bronze';
    }
  }
}
