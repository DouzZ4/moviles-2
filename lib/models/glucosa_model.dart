// lib/models/glucosa_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class GlucosaModel {
  final String id;
  final String idUsuario;
  final double nivel;
  final DateTime fecha;
  final String momento; // Por ejemplo: 'Antes de comer', 'Después de comer'

  GlucosaModel({
    required this.id,
    required this.idUsuario,
    required this.nivel,
    required this.fecha,
    required this.momento,
  });

  // Para Firestore
  factory GlucosaModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GlucosaModel(
      id: documentId,
      idUsuario: data['idUsuario'] ?? '',
      nivel: (data['nivel'] as num?)?.toDouble() ?? 0.0,
      fecha: (data['fecha'] as Timestamp).toDate(),
      momento: data['momento'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idUsuario': idUsuario,
      'nivel': nivel,
      'fecha': fecha,
      'momento': momento,
    };
  }

  // Para SQLite
  factory GlucosaModel.fromSQLite(Map<String, dynamic> map) {
    return GlucosaModel(
      id: map['id'],
      idUsuario: map['idUsuario'],
      nivel: map['nivel'],
      fecha: DateTime.parse(map['fecha']),
      momento: map['momento'],
    );
  }

  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'idUsuario': idUsuario,
      'nivel': nivel,
      'fecha': fecha.toIso8601String(),
      'momento': momento,
    };
  }
}
