import 'package:shared_preferences/shared_preferences.dart';

class StadiumManager {
  static final StadiumManager _instance = StadiumManager._internal();

  factory StadiumManager() {
    return _instance;
  }

  StadiumManager._internal();

  static int _stadiumLevel = 1;
  static int _stadiumUpgradeCost = 100000;

  static int get stadiumLevel => _stadiumLevel;
  static set stadiumLevel(int value) {
    _stadiumLevel = value;
    _instance.saveStadiumLevel();
  }

  static int get stadiumUpgradeCost => _stadiumUpgradeCost;
  static set stadiumUpgradeCost(int value) {
    _stadiumUpgradeCost = value;
    _instance.saveStadiumUpgradeCost();
  }

  Future<void> loadStadiumLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _stadiumLevel = prefs.getInt('stadiumLevel') ?? 1;
  }

  Future<void> saveStadiumLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stadiumLevel', _stadiumLevel);
  }

  Future<void> loadStadiumUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    _stadiumUpgradeCost = prefs.getInt('stadiumUpgradeCost') ?? 100000;
  }

  Future<void> saveStadiumUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stadiumUpgradeCost', _stadiumUpgradeCost);
  }

  Future<void> loadAllStadiumData() async {
    await loadStadiumLevel();
    await loadStadiumUpgradeCost();
  }
}
