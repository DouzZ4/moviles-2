// lib/models/usuario_model.dart

class UsuarioModel {
  final String id;
  final String nombres;
  final String apellidos;
  final int edad;
  final String correo;
  final String username;
  final int documento;

  UsuarioModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.edad,
    required this.correo,
    required this.username,
    required this.documento,
  });

  // Para Firestore
  factory UsuarioModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UsuarioModel(
      id: documentId,
      nombres: data['nombres'] ?? '',
      apellidos: data['apellidos'] ?? '',
      edad: data['edad'] ?? 0,
      correo: data['correo'] ?? '',
      username: data['username'] ?? '',
      documento: data['documento'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'edad': edad,
      'correo': correo,
      'username': username,
      'documento': documento,
    };
  }

  // Para SQLite
  factory UsuarioModel.fromSQLite(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      edad: map['edad'],
      correo: map['correo'],
      username: map['username'],
      documento: map['documento'],
    );
  }

  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'edad': edad,
      'correo': correo,
      'username': username,
      'documento': documento,
    };
  }
}
