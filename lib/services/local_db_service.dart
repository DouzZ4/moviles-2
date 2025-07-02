// lib/services/local_db_service.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBService {
  static final LocalDBService _instance = LocalDBService._internal();
  factory LocalDBService() => _instance;
  LocalDBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'checkinc.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Migración: agrega la columna 'contrasena' si no existe
        final columns = await db.rawQuery("PRAGMA table_info(usuarios)");
        final hasContrasena = columns.any((col) => col['name'] == 'contrasena');
        if (!hasContrasena) {
          await db.execute("ALTER TABLE usuarios ADD COLUMN contrasena TEXT");
        }
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios(
        id TEXT PRIMARY KEY,
        nombres TEXT,
        apellidos TEXT,
        edad INTEGER,
        correo TEXT,
        username TEXT,
        documento INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE glucosa(
        id TEXT PRIMARY KEY,
        valor INTEGER,
        fecha TEXT,
        hora TEXT,
        observaciones TEXT,
        idUsuario TEXT
      )
    ''');
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
