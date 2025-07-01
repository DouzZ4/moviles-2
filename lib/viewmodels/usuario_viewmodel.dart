import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkinc/models/usuario_model.dart';
import 'package:checkinc/services/local_db_service.dart';
import 'package:uuid/uuid.dart';

class UsuarioViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final LocalDBService _localDbService = LocalDBService();
  final Uuid _uuid = Uuid();

  List<UsuarioModel> _usuarios = [];
  String? _error;
  bool _isLoading = false;

  List<UsuarioModel> get usuarios => _usuarios;
  String? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> cargarUsuarios() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('usuarios').get();
      _usuarios = snapshot.docs
          .map((doc) => UsuarioModel.fromMap(doc.data(), doc.id))
          .toList();
      // Opcional: Guardar en SQLite
      for (var u in _usuarios) {
        await _localDbService.insert('usuarios', u.toSQLite());
      }
    } catch (e) {
      _error = 'Error al cargar usuarios: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> agregarUsuario(UsuarioModel nuevo) async {
    try {
      final String nuevoId = _uuid.v4();
      final usuarioConId = UsuarioModel(
        id: nuevoId,
        nombres: nuevo.nombres,
        apellidos: nuevo.apellidos,
        edad: nuevo.edad,
        correo: nuevo.correo,
        username: nuevo.username,
        documento: nuevo.documento,
      );
      await _firestore.collection('usuarios').doc(nuevoId).set(usuarioConId.toMap());
      await _localDbService.insert('usuarios', usuarioConId.toSQLite());
      _usuarios.add(usuarioConId);
      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar usuario: $e';
      notifyListeners();
    }
  }

  Future<void> eliminarUsuario(String id) async {
    try {
      await _firestore.collection('usuarios').doc(id).delete();
      await _localDbService.delete('usuarios', id);
      _usuarios.removeWhere((u) => u.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar usuario: $e';
      notifyListeners();
    }
  }

  void limpiarEstado() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
  Future<void> cargarUsuariosDesdeLocal() async {
  try {
    final datos = await _localDbService.getAll('usuarios');
    _usuarios = datos.map((u) => UsuarioModel.fromSQLite(u)).toList();
    notifyListeners();
  } catch (e) {
    _error = 'Error al cargar usuarios desde SQLite: $e';
    notifyListeners();
  }
}

UsuarioModel? obtenerPorUsernameYDocumento(String username, int documento) {
  try {
    return _usuarios.firstWhere(
      (u) => u.username == username && u.documento == documento,
    );
  } catch (_) {
    return null;
  }
}

}
