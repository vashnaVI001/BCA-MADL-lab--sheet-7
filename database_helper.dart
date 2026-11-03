import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/student.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor();

  static Database? _database;

  // Open the database, or create it the first time the app runs.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'students.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            roll_number TEXT NOT NULL UNIQUE,
            course TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // CREATE: insert() method.
  Future<int> insertStudent(Student student) async {
    final db = await database;
    return db.insert(
      'students',
      student.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // CREATE: rawInsert() method.
  Future<int> rawInsertStudent(Student student) async {
    final db = await database;
    return db.rawInsert(
      'INSERT OR REPLACE INTO students (name, roll_number, course) '
      'VALUES (?, ?, ?)',
      [student.name, student.rollNumber, student.course],
    );
  }

  // READ: query() method.
  Future<List<Student>> getAllStudents() async {
    final db = await database;
    final maps = await db.query('students', orderBy: 'id DESC');
    return maps.map(Student.fromMap).toList();
  }

  // READ: rawQuery() method.
  Future<List<Student>> rawQueryStudents() async {
    final db = await database;
    final maps = await db.rawQuery('SELECT * FROM students ORDER BY id DESC');
    return maps.map(Student.fromMap).toList();
  }

  // UPDATE: update() method.
  Future<int> updateStudent(Student student) async {
    final db = await database;
    return db.update(
      'students',
      student.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  // DELETE: delete() method.
  Future<int> deleteStudent(int id) async {
    final db = await database;
    return db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllStudents() async {
    final db = await database;
    return db.delete('students');
  }

  // Search using a WHERE condition.
  Future<List<Student>> searchByRollNumber(String rollNumber) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'roll_number = ?',
      whereArgs: [rollNumber],
    );
    return maps.map(Student.fromMap).toList();
  }

  // Get students for a selected course.
  Future<List<Student>> getStudentsByCourse(String course) async {
    final db = await database;
    final maps = await db.query(
      'students',
      where: 'course = ?',
      whereArgs: [course],
      orderBy: 'name ASC',
    );
    return maps.map(Student.fromMap).toList();
  }

  // Sort names in ascending or descending order.
  Future<List<Student>> getStudentsOrderedByName({
    bool ascending = true,
  }) async {
    final db = await database;
    final maps = await db.query(
      'students',
      orderBy: 'name ${ascending ? 'ASC' : 'DESC'}',
    );
    return maps.map(Student.fromMap).toList();
  }

  // COUNT(*) returns the total number of records.
  Future<int> getStudentCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) AS total FROM students',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
