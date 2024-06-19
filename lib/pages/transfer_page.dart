import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_eleven/player.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  List<Player> selectedFootballers = [];
  bool _isLoadingImages = true;

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
    await _loadImages();
  }

  Future<void> _loadImages() async {
    await Future.wait(selectedFootballers.map((player) async {
      // Load badge image
      await precacheImage(AssetImage(player.imagePath), context);
      // Load flag image
      await precacheImage(AssetImage(player.flagPath), context);
    }));
    setState(() {
      _isLoadingImages = false;
    });
  }

  Future<void> _generateRandomFootballers() async {
    List<Player> tempList = [];
    for (int i = 0; i < 6; i++) {
      tempList.add(await Player.generateRandomFootballer());
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedFootballers', jsonEncode(tempList));
    setState(() {
      selectedFootballers = tempList;
    });
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
          _isLoadingImages
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Expanded(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
