import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<String>> generateRandomFootballers() async {
  final footballers = [
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

  final random = Random();
  List<String> tempList = [];
  for (int i = 0; i < 6; i++) {
    int randomIndex = random.nextInt(footballers.length);
    String selectedFootballer = footballers[randomIndex];
    tempList.add(selectedFootballer);
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedFootballers', jsonEncode(tempList));
  return tempList;
}
