// lib/viewmodels/glucosa_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkinc/models/glucosa_model.dart';
import 'package:checkinc/services/local_db_service.dart';

class GlucosaViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalDBService _localDbService = LocalDBService();

  List<GlucosaModel> _registros = [];
  bool _isLoading = false;
  String? _error;

  List<GlucosaModel> get registros => _registros;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarRegistros(String idUsuario) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('glucosa')
          .where('idUsuario', isEqualTo: idUsuario)
          .orderBy('fecha', descending: true)
          .get();

      _registros = snapshot.docs
          .map((doc) => GlucosaModel.fromMap(doc.data(), doc.id))
          .toList();

      // También guardar en SQLite
      for (var g in _registros) {
        await _localDbService.insert('glucosa', g.toSQLite());
      }
    } catch (e) {
      _error = 'Error al cargar registros: \$e';
    }

    _isLoading = false;
    notifyListeners();
  }

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
      _error = 'Error al agregar registro: \$e';
      notifyListeners();
    }
  }

  Future<void> eliminarRegistro(String id) async {
    try {
      await _firestore.collection('glucosa').doc(id).delete();
      _registros.removeWhere((g) => g.id == id);
      await _localDbService.delete('glucosa', id);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar registro: \$e';
      notifyListeners();
    }
  }

  void limpiarEstado() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
