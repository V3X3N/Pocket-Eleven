import 'package:shared_preferences/shared_preferences.dart';

class MedicalManager {
  static final MedicalManager _instance = MedicalManager._internal();

  factory MedicalManager() {
    return _instance;
  }

  MedicalManager._internal();

  static int _medicalLevel = 1;
  static int _medicalUpgradeCost = 100000;
  static int _medicalPoints = 50;

  static int get medicalLevel => _medicalLevel;
  static set medicalLevel(int value) {
    _medicalLevel = value;
    _instance.saveMedicalLevel();
  }

  static int get medicalUpgradeCost => _medicalUpgradeCost;
  static set medicalUpgradeCost(int value) {
    _medicalUpgradeCost = value;
    _instance.saveMedicalUpgradeCost();
  }

  static int get medicalPoints => _medicalPoints;
  static set medicalPoints(int value) {
    _medicalPoints = value;
    _instance.saveMedicalPoints();
  }

  Future<void> loadMedicalLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _medicalLevel = prefs.getInt('medicalLevel') ?? 1;
  }

  Future<void> saveMedicalLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('medicalLevel', _medicalLevel);
  }

  Future<void> loadMedicalUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    _medicalUpgradeCost = prefs.getInt('medicalUpgradeCost') ?? 100000;
  }

  Future<void> saveMedicalUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('medicalUpgradeCost', _medicalUpgradeCost);
  }

  Future<void> loadMedicalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _medicalPoints = prefs.getInt('medicalPoints') ?? 50;
  }

  Future<void> saveMedicalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('medicalPoints', _medicalPoints);
  }

  Future<void> loadAllMedicalData() async {
    await loadMedicalLevel();
    await loadMedicalUpgradeCost();
    await loadMedicalPoints();
  }
}
