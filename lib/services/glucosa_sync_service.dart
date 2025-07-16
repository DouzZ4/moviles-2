// lib/services/glucosa_sync_service.dart
// Servicio que sincroniza datos de glucosa entre SQLite y Firebase en la app CheckINC.

import 'package:checkinc/models/glucosa_model.dart';
import 'package:checkinc/services/firestore_service.dart';
import 'package:checkinc/services/local_db_service.dart';

class GlucosaSyncService {
  final _localDB = LocalDBService();
  final _firestore = FirestoreService();

  /// Obtiene los registros de glucosa que aún no han sido sincronizados con Firebase
  Future<List<GlucosaModel>> getNoSincronizados() async {
    final db = await _localDB.database;
    final List<Map<String, dynamic>> result = await db.query(
      'glucosa',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return result.map((map) => GlucosaModel.fromSQLite(map)).toList();
  }

  /// Sincroniza los datos locales no subidos con Firestore
  Future<void> sincronizarGlucosa() async {
    final noSincronizados = await getNoSincronizados();

    for (var glucosa in noSincronizados) {
      try {
        // Sube a Firestore
        await _firestore.createDocument(
          collectionPath: 'glucosa',
          documentId: glucosa.id,
          data: glucosa.toMap(),
        );

        // Marca como sincronizado en SQLite
        final db = await _localDB.database;
        await db.update(
          'glucosa',
          {'sincronizado': 1},
          where: 'id = ?',
          whereArgs: [glucosa.id],
        );
      } catch (e) {
        print('Error al sincronizar glucosa con ID ${glucosa.id}: $e');
      }
    }
  }

  /// Descarga datos de Firestore y los guarda en SQLite (si no existen)
  Future<void> importarDesdeFirestore() async {
    final documentos = await _firestore.getAllDocuments(
      collectionPath: 'glucosa',
    );
    final db = await _localDB.database;

    for (var doc in documentos) {
      final glucosa = GlucosaModel.fromMap(doc.data(), doc.id);

      // Verificar si ya existe localmente
      final local = await db.query(
        'glucosa',
        where: 'id = ?',
        whereArgs: [glucosa.id],
      );

      if (local.isEmpty) {
        await db.insert('glucosa', {...glucosa.toSQLite(), 'sincronizado': 1});
      }
    }
  }
}
