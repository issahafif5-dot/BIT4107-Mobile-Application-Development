import 'dart:io';

import 'package:sqflite/sqflite.dart';

import '../models/student.dart';
import '../models/user.dart';

class DatabaseService {
  DatabaseService._init();

  static final DatabaseService instance = DatabaseService._init();

  static const String _databaseName = 'mini_student_management_app.db';
  static const String studentTable = 'students';
  static const String userTable = 'users';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_databaseName);
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath${Platform.pathSeparator}$fileName';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        await _validateSchema(db);
      },
    );
  }

  Future<void> _validateSchema(Database db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('$userTable', '$studentTable')"
    );

    if (tables.length < 2) {
      await db.execute('DROP TABLE IF EXISTS $userTable');
      await db.execute('DROP TABLE IF EXISTS $studentTable');
      await _createDB(db, 1);
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE $userTable (
        id $idType,
        username $textType UNIQUE,
        email $textType,
        password $textType,
        createdAt $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE $studentTable (
        id $idType,
        uid $textType,
        name $textType,
        age $integerType,
        grade $textType,
        email $textType,
        phone $textType,
        notes TEXT,
        registeredAt $textType
      )
    ''');
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return await db.insert(studentTable, student.toMap());
  }

  Future<List<Student>> fetchStudents() async {
    final db = await database;
    final rows = await db.query(studentTable, orderBy: 'registeredAt DESC');
    return rows.map((row) => Student.fromMap(row)).toList();
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return await db.update(
      studentTable,
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return await db.delete(studentTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert(userTable, user.toMap());
  }

  Future<User?> getUserByUsername(String username) async {
    final db = await database;
    final rows = await db.query(
      userTable,
      where: 'username = ?',
      whereArgs: [username],
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final rows = await db.query(
      userTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
