// usuario_viewmodel.dart
// ViewModel para la gestión de usuarios en la app CheckINC.
// Maneja la lógica de negocio, sincronización con Firestore y SQLite, y notificación de cambios.

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkinc/models/usuario_model.dart';
import 'package:checkinc/services/local_db_service.dart';
import 'package:uuid/uuid.dart';

class UsuarioViewModel with ChangeNotifier {
  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Servicio de base de datos local
  final LocalDBService _localDbService = LocalDBService();
  // Generador de UUIDs para nuevos usuarios
  final Uuid _uuid = Uuid();

  // Lista de usuarios cargados
  List<UsuarioModel> _usuarios = [];
  // Último error producido en operaciones
  String? _error;
  // Estado de carga (loading)
  bool _isLoading = false;

  // Getters públicos para la UI
  List<UsuarioModel> get usuarios => _usuarios;
  String? get error => _error;
  bool get isLoading => _isLoading;

  /// Carga todos los usuarios desde Firestore y los guarda en SQLite
  Future<void> cargarUsuarios() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('usuarios').get();
      _usuarios = snapshot.docs
          .map((doc) => UsuarioModel.fromMap(doc.data(), doc.id))
          .toList();
      // Guarda los usuarios en SQLite localmente
      for (var u in _usuarios) {
        await _localDbService.insert('usuarios', u.toSQLite());
      }
    } catch (e) {
      _error = 'Error al cargar usuarios: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Agrega un usuario nuevo a Firestore y SQLite
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
        contrasena: nuevo.contrasena,
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

  /// Elimina un usuario por ID de Firestore y SQLite
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

  /// Limpia el estado de error y loading
  void limpiarEstado() {
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Carga usuarios desde la base de datos local SQLite
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

  /// Busca un usuario por username y documento
  UsuarioModel? obtenerPorUsernameYDocumento(String username, int documento) {
    try {
      return _usuarios.firstWhere(
        (u) => u.username == username && u.documento == documento,
      );
    } catch (_) {
      return null;
    }
  }

  /// Busca un usuario por username y contraseña
  UsuarioModel? obtenerPorUsernameYContrasena(String username, String contrasena) {
    try {
      return _usuarios.firstWhere(
        (u) => u.username == username && u.contrasena == contrasena,
      );
    } catch (_) {
      return null;
    }
  }
}
