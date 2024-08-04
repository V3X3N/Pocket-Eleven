import 'package:shared_preferences/shared_preferences.dart';

class TrainingManager {
  static final TrainingManager _instance = TrainingManager._internal();

  factory TrainingManager() {
    return _instance;
  }

  TrainingManager._internal();

  static int _trainingLevel = 1;
  static int _trainingUpgradeCost = 100000;
  static int _trainingPoints = 50;

  static int get trainingLevel => _trainingLevel;
  static set trainingLevel(int value) {
    _trainingLevel = value;
    _instance.saveTrainingLevel();
  }

  static int get trainingUpgradeCost => _trainingUpgradeCost;
  static set trainingUpgradeCost(int value) {
    _trainingUpgradeCost = value;
    _instance.saveTrainingUpgradeCost();
  }

  static int get trainingPoints => _trainingPoints;
  static set trainingPoints(int value) {
    _trainingPoints = value;
    _instance.saveTrainingPoints();
  }

  Future<void> loadTrainingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _trainingLevel = prefs.getInt('trainingLevel') ?? 1;
  }

  Future<void> saveTrainingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trainingLevel', _trainingLevel);
  }

  Future<void> loadTrainingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    _trainingUpgradeCost = prefs.getInt('trainingUpgradeCost') ?? 100000;
  }

  Future<void> saveTrainingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trainingUpgradeCost', _trainingUpgradeCost);
  }

  Future<void> loadTrainingPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _trainingPoints = prefs.getInt('trainingPoints') ?? 50;
  }

  Future<void> saveTrainingPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trainingPoints', _trainingPoints);
  }

  Future<void> loadAllTrainingData() async {
    await loadTrainingLevel();
    await loadTrainingUpgradeCost();
    await loadTrainingPoints();
  }
}
