import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'footballers_generator.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 60),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: selectedFootballers.map((name) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.hoverColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textDisabledColor,
                      fontSize: 18,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 60.0),
            height: 80,
            child: MaterialButton(
              onPressed: () async {
                List<String> newFootballers = await generateRandomFootballers();
                setState(() {
                  selectedFootballers = newFootballers;
                });
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
