// glucosa_model.dart
// Modelo de datos para los registros de glucosa en la app CheckINC.
// Permite serialización y deserialización para Firestore y SQLite.

import 'package:cloud_firestore/cloud_firestore.dart';

class GlucosaModel {
  /// Identificador único del registro de glucosa
  final String id;

  /// ID del usuario al que pertenece el registro
  final String idUsuario;

  /// Nivel de glucosa medido (mg/dL)
  final double nivel;

  /// Fecha del registro (DateTime)
  final DateTime fecha;

  /// Momento del día (ejemplo: 'Ayunas', 'Después de comer')
  final String momento;

  /// Indica si el registro está sincronizado con Firestore
  final bool sincronizado;

  /// Constructor del modelo de glucosa
  GlucosaModel({
    required this.id,
    required this.idUsuario,
    required this.nivel,
    required this.fecha,
    required this.momento,
    this.sincronizado = false,
  });

  /// Crea un registro de glucosa a partir de un mapa de Firestore
  factory GlucosaModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GlucosaModel(
      id: documentId,
      idUsuario: data['idUsuario'] ?? '',
      nivel: (data['nivel'] as num?)?.toDouble() ?? 0.0,
      fecha: (data['fecha'] as Timestamp).toDate(),
      momento: data['momento'] ?? '',
    );
  }

  /// Convierte el registro a un mapa para Firestore
  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'nivel': nivel,
      'fecha': fecha,
      'momento': momento,
    };
  }

  /// Crea un registro de glucosa a partir de un mapa de SQLite
  factory GlucosaModel.fromSQLite(Map<String, dynamic> map) {
    return GlucosaModel(
      id: map['id'],
      idUsuario: map['idUsuario'],
      nivel: map['nivel'],
      fecha: DateTime.parse(map['fecha']),
      momento: map['momento'],
      sincronizado: map['sincronizado'] == 1,
    );
  }

  /// Convierte el registro a un mapa para SQLite
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'nivel': nivel,
      'fecha': fecha.toIso8601String(),
      'momento': momento,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  GlucosaModel copyWith({
    String? id,
    String? idUsuario,
    double? nivel,
    DateTime? fecha,
    String? momento,
    bool? sincronizado,
  }) {
    return GlucosaModel(
      id: id ?? this.id,
      idUsuario: idUsuario ?? this.idUsuario,
      nivel: nivel ?? this.nivel,
      fecha: fecha ?? this.fecha,
      momento: momento ?? this.momento,
      sincronizado: sincronizado ?? this.sincronizado,
    );
  }
}
