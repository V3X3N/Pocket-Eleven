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
  double _money = 500000.0;
  int _trainingPoints = 50;
  int _medicalPoints = 50;
  int _youthPoints = 50;

  // Static getters and setters to access the properties
  static double get money => _instance._money;
  static set money(double value) {
    _instance._money = value;
    _instance.saveMoney();
  }

  static int get trainingPoints => _instance._trainingPoints;
  static set trainingPoints(int value) {
    _instance._trainingPoints = value;
    _instance.saveTrainingPoints();
  }

  static int get medicalPoints => _instance._medicalPoints;
  static set medicalPoints(int value) {
    _instance._medicalPoints = value;
    _instance.saveMedicalPoints();
  }

  static int get youthPoints => _instance._youthPoints;
  static set youthPoints(int value) {
    _instance._youthPoints = value;
    _instance.saveYouthPoints();
  }

  // Load and save methods
  Future<void> loadMoney() async {
    final prefs = await SharedPreferences.getInstance();
    _money = prefs.getDouble('money') ?? 50000.0;
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
