import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  // Singleton instance
  static final UserManager _instance = UserManager._internal();

  // Factory constructor
  factory UserManager() {
    return _instance;
  }

  // Private constructor
  UserManager._internal();

  // Private properties
  static double _money = 500000.0;
  static int _trainingPoints = 50;
  static int _medicalPoints = 50;
  static int _youthPoints = 50;

  // Nowe właściwości
  static int stadiumLevel = 1;
  static int upgradeCost = 100000;

  // Static getters and setters to access the properties
  static double get money => _money;
  static set money(double value) {
    _money = value;
    _instance.saveMoney();
  }

  static int get trainingPoints => _trainingPoints;
  static set trainingPoints(int value) {
    _trainingPoints = value;
    _instance.saveTrainingPoints();
  }

  static int get medicalPoints => _medicalPoints;
  static set medicalPoints(int value) {
    _medicalPoints = value;
    _instance.saveMedicalPoints();
  }

  static int get youthPoints => _youthPoints;
  static set youthPoints(int value) {
    _youthPoints = value;
    _instance.saveYouthPoints();
  }

  // Nowe metody do ładowania i zapisywania poziomu stadionu i kosztu
  Future<void> loadStadiumLevel() async {
    final prefs = await SharedPreferences.getInstance();
    stadiumLevel = prefs.getInt('stadiumLevel') ?? 1;
  }

  Future<void> saveStadiumLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stadiumLevel', stadiumLevel);
  }

  Future<void> loadUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    upgradeCost = prefs.getInt('upgradeCost') ?? 100000;
  }

  Future<void> saveUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('upgradeCost', upgradeCost);
  }

  // Load and save methods
  Future<void> loadMoney() async {
    final prefs = await SharedPreferences.getInstance();
    _money = prefs.getDouble('money') ?? 500000.0;
  }

  Future<void> saveMoney() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('money', _money);
  }

  Future<void> loadTrainingPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _trainingPoints = prefs.getInt('trainingPoints') ?? 50;
  }

  Future<void> saveTrainingPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trainingPoints', _trainingPoints);
  }

  Future<void> loadMedicalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _medicalPoints = prefs.getInt('medicalPoints') ?? 50;
  }

  Future<void> saveMedicalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('medicalPoints', _medicalPoints);
  }

  Future<void> loadYouthPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _youthPoints = prefs.getInt('youthPoints') ?? 50;
  }

  Future<void> saveYouthPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('youthPoints', _youthPoints);
  }
}
