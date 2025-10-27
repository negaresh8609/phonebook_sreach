// lib/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'person_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'contacts.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE people (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        school TEXT NOT NULL,
        position TEXT NOT NULL,
        phoneNumber TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertPersons(List<Person> people) async {
    final db = await database;
    Batch batch = db.batch();
    for (var person in people) {
      batch.insert('people', person.toMap()..remove('id'), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }
  
  Future<void> clearPersons() async {
    final db = await database;
    await db.delete('people');
  }

  Future<List<Person>> getAllPersons() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('people');

    if (maps.isEmpty) {
      return [];
    }
    
    return List.generate(maps.length, (i) => Person.fromMap(maps[i]));
  }
}
