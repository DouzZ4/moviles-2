// lib/services/local_db_service.dart
// Servicio para el manejo de la base de datos local SQLite en la app CheckINC.
// Permite operaciones CRUD y migraciones automáticas.

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class LocalDBService {
  // Instancia singleton del servicio
  static final LocalDBService _instance = LocalDBService._internal();
  factory LocalDBService() => _instance;
  LocalDBService._internal();

  // Referencia a la base de datos SQLite
  Database? _db;

  /// Obtiene la base de datos, inicializándola si es necesario
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  /// Inicializa la base de datos y aplica migraciones si es necesario
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

  /// Crea las tablas iniciales de la base de datos
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

  /// Inserta un registro en la tabla especificada
  Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Obtiene todos los registros de una tabla
  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  /// Actualiza un registro por ID en la tabla especificada
  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  /// Elimina un registro por ID en la tabla especificada
  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
