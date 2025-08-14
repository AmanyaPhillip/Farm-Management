// filepath: c:\dev\Apps\maps_Example\google_maps_in_flutter\lib\database_helper.dart
import 'dart:async';
import 'dart:convert'; // Added for JSON encoding
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Create the users table with an additional 'role' column
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL,
            password TEXT NOT NULL,
            role INTEGER NOT NULL
          )
        ''');

        // Insert predefined users with roles
        await db.insert(
          'users',
          {'username': 'Admin', 'password': 'admin', 'role': 1}, // Admin role
        );
        await db.insert(
          'users',
          {'username': 'phill', 'password': 'phil1', 'role': 2}, // Regular user role
        );
      },
    );
  }

  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return await db.insert(
      'users',
      {'username': username, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['id', 'username', 'password', 'role'], // Include the role column
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty ? result.first : null;
  }
}

class InventoryDatabaseHelper {
  static final InventoryDatabaseHelper _instance = InventoryDatabaseHelper._internal();
  factory InventoryDatabaseHelper() => _instance;

  static Database? _database;

  InventoryDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'inventory_database.db');

    return await openDatabase(
      path,
      version: 7, // Increment the version to trigger schema updates
      onCreate: (db, version) async {
        // Create the inventory table
        await db.execute('''
          CREATE TABLE inventory (
            cow_id TEXT PRIMARY KEY,
            alive INTEGER NOT NULL,
            cow_name TEXT NOT NULL,
            farm TEXT NOT NULL,
            breed TEXT NOT NULL
          )
        ''');

        // Create the vacTable
        await db.execute('''
          CREATE TABLE vacTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cow_id TEXT NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL,
            FOREIGN KEY (cow_id) REFERENCES inventory (cow_id) ON DELETE CASCADE
          )
        ''');

        // Create the dipTable
        await db.execute('''
          CREATE TABLE dipTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cow_id TEXT NOT NULL,
            date TEXT NOT NULL,
            status TEXT NOT NULL,
            FOREIGN KEY (cow_id) REFERENCES inventory (cow_id) ON DELETE CASCADE
          )
        ''');

        // Create the milkTable
        await db.execute('''
          CREATE TABLE milkTable (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cow_id TEXT NOT NULL,
            date TEXT NOT NULL,
            liters REAL NOT NULL,
            FOREIGN KEY (cow_id) REFERENCES inventory (cow_id) ON DELETE CASCADE
          )
        ''');

        // Create the FamilyTreeTable
        await db.execute('''
          CREATE TABLE FamilyTreeTable (
            cow_id TEXT PRIMARY KEY,
            parent1 TEXT NOT NULL,
            parent2 TEXT NOT NULL,
            kids TEXT NOT NULL, -- Store the list of kids as a JSON string
            FOREIGN KEY (cow_id) REFERENCES inventory (cow_id) ON DELETE CASCADE,
            FOREIGN KEY (parent1) REFERENCES inventory (cow_id) ON DELETE CASCADE,
            FOREIGN KEY (parent2) REFERENCES inventory (cow_id) ON DELETE CASCADE,
            CONSTRAINT unique_cow_id UNIQUE (cow_id),
            CONSTRAINT no_duplicate_parents CHECK (parent1 != parent2)
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Add the breed column to the existing table
          await db.execute('ALTER TABLE inventory ADD COLUMN breed TEXT NOT NULL DEFAULT ""');
        }
        if (oldVersion < 4) {
          // Create the vacTable if upgrading from an older version
          await db.execute('''
            CREATE TABLE vacTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cow_id TEXT NOT NULL,
              date TEXT NOT NULL,
              status TEXT NOT NULL,
              FOREIGN KEY (cow_id) REFERENCES inventory (cow_id) ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 5) {
          // Create the dipTable if upgrading from an older version
          await db.execute('''
            CREATE TABLE dipTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cow_id TEXT NOT NULL,
              date TEXT NOT NULL,
              status TEXT NOT NULL,
              FOREIGN KEY (cow_id) REFERENCES inventory (cow_id) ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 6) {
          // Create the milkTable if upgrading from an older version
          await db.execute('''
            CREATE TABLE milkTable (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              cow_id TEXT NOT NULL,
              date TEXT NOT NULL,
              liters REAL NOT NULL,
              FOREIGN KEY (cow_id) REFERENCES inventory (cow_id) ON DELETE CASCADE
            )
          ''');
        }
        if (oldVersion < 7) {
          // Create the FamilyTreeTable if upgrading from an older version
          await db.execute('''
            CREATE TABLE FamilyTreeTable (
              cow_id TEXT PRIMARY KEY,
              parent1 TEXT NOT NULL,
              parent2 TEXT NOT NULL,
              kids TEXT NOT NULL, -- Store the list of kids as a JSON string
              FOREIGN KEY (cow_id) REFERENCES inventory (cow_id) ON DELETE CASCADE,
              FOREIGN KEY (parent1) REFERENCES inventory (cow_id) ON DELETE CASCADE,
              FOREIGN KEY (parent2) REFERENCES inventory (cow_id) ON DELETE CASCADE,
              CONSTRAINT unique_cow_id UNIQUE (cow_id),
              CONSTRAINT no_duplicate_parents CHECK (parent1 != parent2)
            )
          ''');
        }
      },
    );
  }

  Future<void> insertCow(String cowId, bool alive, String cowName, String farm, String breed) async {
    final db = await database;
    await db.insert(
      'inventory',
      {
        'cow_id': cowId,
        'alive': alive ? 1 : 0, // Convert boolean to integer (1 = true, 0 = false)
        'cow_name': cowName,
        'farm': farm,
        'breed': breed,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllCows() async {
    final db = await database;
    return await db.query('inventory');
  }

  Future<void> clearInventory() async {
    final db = await database;
    await db.delete('inventory');
  }

  Future<void> updateCowBreed(String cowId, String newBreed) async {
    final db = await database;
    await db.update(
      'inventory',
      {'breed': newBreed},
      where: 'cow_id = ?',
      whereArgs: [cowId],
    );
  }

  // Insert a vaccination record into vacTable
  Future<void> insertVaccination(String cowId, String date, String status) async {
    final db = await database;
    await db.insert(
      'vacTable',
      {
        'cow_id': cowId,
        'date': date,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all vaccination records for a specific cow
  Future<List<Map<String, dynamic>>> getVaccinationRecords(String cowId) async {
    final db = await database;
    return await db.query(
      'vacTable',
      where: 'cow_id = ?',
      whereArgs: [cowId],
    );
  }

  // Clear all vaccination records (for testing purposes)
  Future<void> clearVaccinationTable() async {
    final db = await database;
    await db.delete('vacTable');
  }

  // Insert a dipping record into dipTable
  Future<void> insertDipping(String cowId, String date, String status) async {
    final db = await database;
    await db.insert(
      'dipTable',
      {
        'cow_id': cowId,
        'date': date,
        'status': status,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all dipping records for a specific cow
  Future<List<Map<String, dynamic>>> getDippingRecords(String cowId) async {
    final db = await database;
    return await db.query(
      'dipTable',
      where: 'cow_id = ?',
      whereArgs: [cowId],
    );
  }

  // Clear all dipping records (for testing purposes)
  Future<void> clearDippingTable() async {
    final db = await database;
    await db.delete('dipTable');
  }

  Future<void> updateCowName(String cowId, String newName) async {
    final db = await database;
    await db.update(
      'inventory',
      {'cow_name': newName},
      where: 'cow_id = ?',
      whereArgs: [cowId],
    );
  }

  Future<void> updateCowFarm(String cowId, String newFarm) async {
    final db = await database;
    await db.update(
      'inventory',
      {'farm': newFarm},
      where: 'cow_id = ?',
      whereArgs: [cowId],
    );
  }

  // Insert a milk record into milkTable
  Future<void> insertMilk(String cowId, String date, double liters) async {
    final db = await database;
    await db.insert(
      'milkTable',
      {
        'cow_id': cowId,
        'date': date,
        'liters': liters,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all milk records for a specific cow
  Future<List<Map<String, dynamic>>> getMilkRecords(String cowId) async {
    final db = await database;
    return await db.query(
      'milkTable',
      where: 'cow_id = ?',
      whereArgs: [cowId],
    );
  }

  // Clear all milk records (for testing purposes)
  Future<void> clearMilkTable() async {
    final db = await database;
    await db.delete('milkTable');
  }

  // Insert a family tree record into FamilyTreeTable
  Future<void> insertFamilyTreeRecord(String cowId, String parent1, String parent2, List<String> kids) async {
    final db = await database;
    final kidsJson = jsonEncode(kids); // Convert the list of kids to a JSON string
    await db.insert(
      'FamilyTreeTable',
      {
        'cow_id': cowId,
        'parent1': parent1,
        'parent2': parent2,
        'kids': kidsJson,
      },
      conflictAlgorithm: ConflictAlgorithm.replace, // Replace if the record already exists
    );
  }

  Future<Map<String, dynamic>?> getFamilyTreeRecord(String cowId) async {
    final db = await database;
    final result = await db.query(
      'FamilyTreeTable',
      where: 'cow_id = ?',
      whereArgs: [cowId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getCowById(String cowId) async {
    final db = await database;
    final result = await db.query(
      'inventory',
      where: 'cow_id = ?',
      whereArgs: [cowId],
    );
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}