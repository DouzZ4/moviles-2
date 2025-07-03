// Modelo de usuario para la app CheckINC.
// Incluye serialización para Firestore y SQLite.

class UsuarioModel {
  /// Identificador único del usuario
  final String id;
  /// Nombres del usuario
  final String nombres;
  /// Apellidos del usuario
  final String apellidos;
  /// Edad del usuario
  final int edad;
  /// Correo electrónico del usuario
  final String correo;
  /// Nombre de usuario (username) para login
  final String username;
  /// Documento de identidad del usuario
  final int documento;
  /// Contraseña del usuario (texto plano, solo para pruebas)
  final String contrasena;

  /// Constructor del modelo de usuario
  UsuarioModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.edad,
    required this.correo,
    required this.username,
    required this.documento,
    required this.contrasena,
  });

  /// Crea un usuario a partir de un mapa (Firestore)
  factory UsuarioModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UsuarioModel(
      id: documentId,
      nombres: data['nombres'] ?? '',
      apellidos: data['apellidos'] ?? '',
      edad: data['edad'] ?? 0,
      correo: data['correo'] ?? '',
      username: data['username'] ?? '',
      documento: data['documento'] ?? 0,
      contrasena: data['contrasena'] ?? '',
    );
  }

  /// Convierte el usuario a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'edad': edad,
      'correo': correo,
      'username': username,
      'documento': documento,
      'contrasena': contrasena,
    };
  }

  /// Crea un usuario a partir de un mapa de SQLite
  factory UsuarioModel.fromSQLite(Map<String, dynamic> map) {
    return UsuarioModel(
      id: map['id'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      edad: map['edad'],
      correo: map['correo'],
      username: map['username'],
      documento: map['documento'],
      contrasena: map['contrasena'],
    );
  }

  /// Convierte el usuario a un mapa para SQLite
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'edad': edad,
      'correo': correo,
      'username': username,
      'documento': documento,
      'contrasena': contrasena,
    };
  }
}
