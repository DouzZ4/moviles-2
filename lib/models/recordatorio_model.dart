import 'package:cloud_firestore/cloud_firestore.dart';

class RecordatorioModel {
  String id;
  String titulo;
  String descripcion;
  DateTime fecha;
  String idUsuario;
  bool sincronizado = false;

  RecordatorioModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.idUsuario,
    this.sincronizado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
      'idUsuario': idUsuario,
      'sincronizado': sincronizado ? 1 : 0,
    };
  }

  factory RecordatorioModel.fromMap(Map<String, dynamic> map) {
    return RecordatorioModel(
      id: map['id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      fecha: DateTime.parse(map['fecha']),
      idUsuario: map['idUsuario'],
      sincronizado: map['sincronizado'] == 1,
    );
  }
}
