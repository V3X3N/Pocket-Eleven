import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({Key? key}) : super(key: key);

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
    final _random = Random();
    List<Player> tempList = [];
    for (int i = 0; i < 6; i++) {
      int randomIndex = _random.nextInt(footballers.length);
      String selectedFootballer = footballers[randomIndex];
      int ovr = _random.nextInt(230) + 21;
      String imagePath = _getImagePath(ovr);
      tempList.add(
          Player(name: selectedFootballer, ovr: ovr, imagePath: imagePath));
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
                                  player.name,
                                  style: const TextStyle(
                                    color: AppColors.textEnabledColor,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(
                                  'Badge: ${player.badge}',
                                  style: const TextStyle(
                                    color: AppColors.textEnabledColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 60,
                          child: Container(
                            margin: const EdgeInsets.only(right: 18),
                            child: Text(
                              '${player.ovr}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppColors.textEnabledColor,
                                fontSize: 18,
                              ),
                            ),
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
  final int ovr;
  final String imagePath;
  late final String badge;

  Player({required this.name, required this.ovr, required this.imagePath}) {
    badge = _calculateBadge();
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      ovr: json['ovr'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ovr': ovr,
      'imagePath': imagePath,
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
