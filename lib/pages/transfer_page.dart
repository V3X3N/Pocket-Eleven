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

  List<String> selectedFootballers = [];

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
        selectedFootballers = List<String>.from(jsonDecode(footballersJson));
      });
    }
  }

  Future<void> _generateRandomFootballers() async {
    final _random = Random();
    List<String> tempList = [];
    for (int i = 0; i < 6; i++) {
      int randomIndex = _random.nextInt(footballers.length);
      String selectedFootballer = footballers[randomIndex];
      tempList.add(selectedFootballer);
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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Column(
            children: selectedFootballers.map((name) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              );
            }).toList(),
          ),
          Expanded(
            child: Container(),
          ),
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
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
