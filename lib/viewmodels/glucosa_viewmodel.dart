// glucosa_viewmodel.dart
// ViewModel para la gestión de registros de glucosa en la app CheckINC.
// Sincroniza datos entre Firestore, SQLite y la UI, y maneja la lógica de negocio.

import 'package:checkinc/services/glucosa_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkinc/models/glucosa_model.dart';
import 'package:checkinc/services/local_db_service.dart';
import 'package:uuid/uuid.dart';

class GlucosaViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalDBService _localDbService = LocalDBService();
  final GlucosaSyncService _syncService = GlucosaSyncService();

  List<GlucosaModel> _registros = [];
  bool _isLoading = false;
  String? _error;

  List<GlucosaModel> get registros => _registros;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga registros desde SQLite (offline) y sincroniza con Firestore
  Future<void> cargarRegistrosLocal(String idUsuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final db = await _localDbService.database;
      final result = await db.query(
        'glucosa',
        where: 'idUsuario = ?',
        whereArgs: [idUsuario],
        orderBy: 'fecha DESC',
      );

      _registros = result.map((e) => GlucosaModel.fromSQLite(e)).toList();
    } catch (e) {
      _error = 'Error al cargar datos locales: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Agrega un nuevo registro solo en SQLite y lo sincroniza luego
  Future<void> agregarRegistro(GlucosaModel nuevo) async {
    try {
      final nuevoId = const Uuid().v4();
      final nuevoLocal = GlucosaModel(
        id: nuevoId,
        idUsuario: nuevo.idUsuario,
        nivel: nuevo.nivel,
        fecha: nuevo.fecha,
        momento: nuevo.momento,
        sincronizado: false,
      );

      await _localDbService.insert('glucosa', nuevoLocal.toSQLite());
      _registros.insert(0, nuevoLocal);
      notifyListeners();

      // Sincronización no requiere notifyListeners ni cambios de estado local
      sincronizarDatos();
    } catch (e) {
      _error = 'Error al agregar registro: $e';
      notifyListeners();
    }
  }

  /// Elimina un registro de ambas fuentes
  Future<void> eliminarRegistro(String id) async {
    try {
      await _firestore.collection('glucosa').doc(id).delete();
    } catch (_) {}

    await _localDbService.delete('glucosa', id);
    _registros.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  /// Actualiza un registro en SQLite y lo marca para sincronización
  Future<void> actualizarRegistro(GlucosaModel actualizado) async {
    try {
      await _localDbService.update(
        'glucosa',
        actualizado.copyWith(sincronizado: false).toSQLite(),
        actualizado.id,
      );
      final index = _registros.indexWhere((g) => g.id == actualizado.id);
      if (index != -1) {
        _registros[index] = actualizado;
        notifyListeners();
      }
      // Sincronización no requiere notifyListeners ni cambios de estado local
      sincronizarDatos();
    } catch (e) {
      _error = 'Error al actualizar: $e';
      notifyListeners();
    }
  }

  /// Limpia el estado
  void limpiarEstado() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Sincroniza datos entre SQLite y Firebase
  Future<void> sincronizarDatos() async {
    await _syncService.sincronizarGlucosa();
    // No llamar a notifyListeners aquí, a menos que cambie el estado local
  }

  /// Importa desde Firebase y guarda localmente (primer uso o reconexión)
  Future<void> importarDesdeFirestore() async {
    await _syncService.importarDesdeFirestore();
  }
}
