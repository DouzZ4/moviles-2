// lib/services/auth_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _usuariosRef =
      FirebaseFirestore.instance.collection('usuarios');

  // Registrar un nuevo usuario en Firestore
  Future<void> registerUser(UsuarioModel usuario) async {
    try {
      await _usuariosRef.doc(usuario.id).set(usuario.toMap());
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  // Autenticación simple por username y correo (se puede adaptar a Firebase Auth si lo deseas)
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

  // Obtener usuario por ID
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
