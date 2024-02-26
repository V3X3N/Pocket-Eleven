import 'dart:io';
import 'dart:math';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_name_generator/random_name_generator.dart';

class DatabaseHelper {
  var randomNames = RandomNames(Zone.us);

  static const _databaseName = 'LeagueDB.db';
  static const _databaseVersion = 1;

  static const tableClubs = 'clubs';
  static const tablePlayers = 'players';
  static const columnId = '_id';
  static const columnName = 'name';
  static const columnPoints = 'points';
  static const columnMatchesPlayed = 'matches_played';
  static const columnMatchesWon = 'matches_won';
  static const columnMatchesDrawn = 'matches_drawn';
  static const columnMatchesLost = 'matches_lost';
  static const columnGoalsFor = 'goals_for';
  static const columnGoalsAgainst = 'goals_against';
  static const columnClubId = 'club_id';
  static const columnFirstName = 'first_name';
  static const columnLastName = 'last_name';
  static const columnPosition = 'position';
  static const columnTackling = 'tackling';
  static const columnMarking = 'marking';
  static const columnPositioning = 'positioning';
  static const columnHeading = 'heading';
  static const columnPassing = 'passing';
  static const columnDribbling = 'dribbling';
  static const columnShooting = 'shooting';
  static const columnFinishing = 'finishing';
  static const columnFitness = 'fitness';
  static const columnAggression = 'aggression';
  static const columnSpeed = 'speed';
  static const columnBallControl = 'ball_control';
  static const columnCreatedByPlayer = 'created_by_player';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> initializeDatabaseIfNeeded() async {
    if (!await databaseExists()) {
      await _initDatabase();
    }
  }

  Future<bool> databaseExists() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return databaseFactory.databaseExists(path);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableClubs (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnPoints INTEGER DEFAULT 0,
        $columnMatchesPlayed INTEGER DEFAULT 0,
        $columnMatchesWon INTEGER DEFAULT 0,
        $columnMatchesDrawn INTEGER DEFAULT 0,
        $columnMatchesLost INTEGER DEFAULT 0,
        $columnGoalsFor INTEGER DEFAULT 0,
        $columnGoalsAgainst INTEGER DEFAULT 0,
        $columnCreatedByPlayer INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE $tablePlayers (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnClubId INTEGER NOT NULL,
        $columnFirstName TEXT NOT NULL,
        $columnLastName TEXT NOT NULL,
        $columnPosition TEXT NOT NULL,
        $columnTackling INTEGER DEFAULT 0,
        $columnMarking INTEGER DEFAULT 0,
        $columnPositioning INTEGER DEFAULT 0,
        $columnHeading INTEGER DEFAULT 0,
        $columnPassing INTEGER DEFAULT 0,
        $columnDribbling INTEGER DEFAULT 0,
        $columnShooting INTEGER DEFAULT 0,
        $columnFinishing INTEGER DEFAULT 0,
        $columnFitness INTEGER DEFAULT 0,
        $columnAggression INTEGER DEFAULT 0,
        $columnSpeed INTEGER DEFAULT 0,
        $columnBallControl INTEGER DEFAULT 0
      )
    ''');

    // Inicjalizacja klubów i graczy
    for (int i = 1; i <= 19; i++) {
      int clubId = await db.insert(tableClubs, {
        columnName: generateRandomClubName(),
        columnPoints: 0,
        columnMatchesPlayed: 0,
        columnMatchesWon: 0,
        columnMatchesDrawn: 0,
        columnMatchesLost: 0,
        columnGoalsFor: 0,
        columnGoalsAgainst: 0,
        columnCreatedByPlayer: 0, // Ustawienie domyślnej wartości
      });

      for (int j = 1; j <= 19; j++) {
        await db.insert(tablePlayers, {
          columnClubId: clubId,
          columnFirstName: randomNames.manName(),
          columnLastName: randomNames.surname(),
          columnPosition: generateRandomPosition(),
          columnTackling: generateRandomSkill(),
          columnMarking: generateRandomSkill(),
          columnPositioning: generateRandomSkill(),
          columnHeading: generateRandomSkill(),
          columnPassing: generateRandomSkill(),
          columnDribbling: generateRandomSkill(),
          columnShooting: generateRandomSkill(),
          columnFinishing: generateRandomSkill(),
          columnFitness: generateRandomSkill(),
          columnAggression: generateRandomSkill(),
          columnSpeed: generateRandomSkill(),
          columnBallControl: generateRandomSkill(),
        });
      }
    }
  }

  Future<void> addNewClub(String clubName,
      {required bool createdByPlayer}) async {
    // Close the existing database if it's open
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }

    // Delete the old database file
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String oldPath = join(documentsDirectory.path, _databaseName);
    await deleteDatabase(oldPath);

    // Create a new database
    Database db = await instance.database;
    int clubId = await db.insert(tableClubs, {
      columnName: clubName,
      columnPoints: 0,
      columnMatchesPlayed: 0,
      columnMatchesWon: 0,
      columnMatchesDrawn: 0,
      columnMatchesLost: 0,
      columnGoalsFor: 0,
      columnGoalsAgainst: 0,
      columnCreatedByPlayer: createdByPlayer ? 1 : 0,
    });

    for (int j = 1; j <= 19; j++) {
      await db.insert(tablePlayers, {
        columnClubId: clubId,
        columnFirstName: randomNames.manName(),
        columnLastName: randomNames.surname(),
        columnPosition: generateRandomPosition(),
        columnTackling: generateRandomSkill(),
        columnMarking: generateRandomSkill(),
        columnPositioning: generateRandomSkill(),
        columnHeading: generateRandomSkill(),
        columnPassing: generateRandomSkill(),
        columnDribbling: generateRandomSkill(),
        columnShooting: generateRandomSkill(),
        columnFinishing: generateRandomSkill(),
        columnFitness: generateRandomSkill(),
        columnAggression: generateRandomSkill(),
        columnSpeed: generateRandomSkill(),
        columnBallControl: generateRandomSkill(),
      });
    }
  }

  String generateRandomClubName() {
    final List<String> clubNamePrefixes = [
      'Red','Blue','Green','White','Black','Golden','Silver','City','United','Epic',
      'Real','FC','Athletic','Sporting','Olympic','Mighty','Dynamic','Harmonious',
      'Royal','Magical','Flying','Eternal','Daring','Infinite','Victorious','Majestic',
      'Fierce','Brave','Spartan''Elite','Celestial','Supreme','Galactic','Valiant',
      'Noble','Radiant','Grand','Mystic','Ethereal','Legendary','Cosmic','Powerful',
      'Invincible','Astral','Serene','Prestigious','Majestic','Elegant','Imperial'
    ];

    final List<String> clubNameSuffixes = [
      'Stars','Lions','Eagles','Warriors','Wolves','Hawks','Tigers','Falcons','Bulls',
      'Dragons','Panthers','Cobras','Phoenix','Storm','Blaze','Raiders','Chargers',
      'Spartans','Knights','Guardians','Titans','Raptors','Legends','Vanguards'
      'Rebels','Warlocks','Wizards','Gladiators','Cyclones','Strikers','Blasters','Vipers',
      'Monarchs','Ravens','Wraiths','Thunder','Sorcerers','Fury','Aces','Wanderers',
      'Cruisers','Voyagers','Patriots','Saviors','Specters','Prowlers','Envoys','Crusaders'
    ];

    final Random random = Random();
    final String prefix =
        clubNamePrefixes[random.nextInt(clubNamePrefixes.length)];
    final String suffix =
        clubNameSuffixes[random.nextInt(clubNameSuffixes.length)];
    return '$prefix $suffix';
  }

  String generateRandomPosition() {
    final List<String> positions = ['Forward', 'Midfielder', 'Defender'];
    final Random random = Random();
    return positions[random.nextInt(positions.length)];
  }

  int generateRandomSkill() {
    final Random random = Random();
    return random.nextInt(20) + 1;
  }

  Future<Map<String, dynamic>?> getClubById(int clubId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> clubs =
        await db.query(tableClubs, where: '$columnId = ?', whereArgs: [clubId]);

    if (clubs.isNotEmpty) {
      return clubs.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getClubs() async {
    Database db = await instance.database;
    return await db.query(tableClubs);
  }

  Future<List<Map<String, dynamic>>> getPlayersByClubId(int clubId) async {
    Database db = await instance.database;
    return await db
        .query(tablePlayers, where: '$columnClubId = ?', whereArgs: [clubId]);
  }

  Future<Map<String, dynamic>?> getPlayerClub() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> clubs = await db.query(
      tableClubs,
      where: '$columnCreatedByPlayer = ?',
      whereArgs: [1],
    );

    if (clubs.isNotEmpty) {
      return clubs.first;
    } else {
      return null;
    }
  }
}
