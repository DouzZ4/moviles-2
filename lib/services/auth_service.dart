// lib/services/auth_service.dart
// Servicio de autenticación y gestión de usuarios para la app CheckINC.
// Permite registrar, autenticar y obtener usuarios desde Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class AuthService {
  // Instancia de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Referencia a la colección de usuarios
  final CollectionReference _usuariosRef =
      FirebaseFirestore.instance.collection('usuarios');

  /// Registra un nuevo usuario en Firestore
  /// Lanza una excepción si ocurre un error
  Future<void> registerUser(UsuarioModel usuario) async {
    try {
      await _usuariosRef.doc(usuario.id).set(usuario.toMap());
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  /// Autenticación simple por username y correo
  /// Devuelve el usuario si existe, o null si no se encuentra
  /// (Se puede adaptar a Firebase Auth si se requiere seguridad real)
  Future<UsuarioModel?> login(String username, String correo) async {
    try {
      QuerySnapshot snapshot = await _usuariosRef
          .where('username', isEqualTo: username)
          .where('correo', isEqualTo: correo)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return UsuarioModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Obtiene un usuario por su ID
  /// Devuelve el usuario si existe, o null si no se encuentra
  Future<UsuarioModel?> getUsuarioById(String id) async {
    try {
      final doc = await _usuariosRef.doc(id).get();
      if (doc.exists) {
        return UsuarioModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener usuario: $e');
    }
  }
}
