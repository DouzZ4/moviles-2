// glucosa_viewmodel.dart
// ViewModel para la gestión de registros de glucosa en la app CheckINC.
// Sincroniza datos entre Firestore, SQLite y la UI, y maneja la lógica de negocio.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkinc/models/glucosa_model.dart';
import 'package:checkinc/services/local_db_service.dart';

class GlucosaViewModel with ChangeNotifier {
  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Servicio de base de datos local
  final LocalDBService _localDbService = LocalDBService();

  // Lista de registros de glucosa cargados
  List<GlucosaModel> _registros = [];
  // Estado de carga (loading)
  bool _isLoading = false;
  // Último error producido en operaciones
  String? _error;

  // Getters públicos para la UI
  List<GlucosaModel> get registros => _registros;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Carga todos los registros de glucosa de un usuario desde Firestore y los guarda en SQLite
  Future<void> cargarRegistros(String idUsuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot =
          await _firestore
              .collection('glucosa')
              .where('idUsuario', isEqualTo: idUsuario)
              .orderBy('fecha', descending: true)
              .get();

      _registros =
          snapshot.docs
              .map((doc) => GlucosaModel.fromMap(doc.data(), doc.id))
              .toList();

      // Guarda los registros en SQLite localmente
      for (var g in _registros) {
        await _localDbService.insert('glucosa', g.toSQLite());
      }
    } catch (e) {
      _error = 'Error al cargar registros: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Agrega un nuevo registro de glucosa a Firestore y SQLite
  Future<void> agregarRegistro(GlucosaModel nuevo) async {
    try {
      final docRef = await _firestore.collection('glucosa').add(nuevo.toMap());

      final nuevoConId = GlucosaModel(
        id: docRef.id,
        idUsuario: nuevo.idUsuario,
        nivel: nuevo.nivel,
        fecha: nuevo.fecha,
        momento: nuevo.momento,
      );

      _registros.insert(0, nuevoConId);
      await _localDbService.insert('glucosa', nuevoConId.toSQLite());
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar registro: $e';
      notifyListeners();
    }
  }

  /// Elimina un registro de glucosa por ID de Firestore y SQLite
  Future<void> eliminarRegistro(String id) async {
    try {
      await _firestore.collection('glucosa').doc(id).delete();
      _registros.removeWhere((g) => g.id == id);
      await _localDbService.delete('glucosa', id);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar registro: $e';
      notifyListeners();
    }
  }

  /// Limpia el estado de error y loading
  void limpiarEstado() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> actualizarRegistro(GlucosaModel nuevo) async {}
}
