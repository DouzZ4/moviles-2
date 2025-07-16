import 'package:checkinc/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RecordatorioFormView extends StatefulWidget {
  const RecordatorioFormView({super.key});

  @override
  State<RecordatorioFormView> createState() => _RecordatorioFormViewState();
}

class _RecordatorioFormViewState extends State<RecordatorioFormView> {
  final _formKey = GlobalKey<FormState>();

  String _titulo = '';
  String _descripcion = '';
  DateTime? _fechaHora;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  Future<void> _pickDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 8, minute: 0),
      );

      if (time != null) {
        setState(() {
          _fechaHora = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _guardarRecordatorio() async {
    if (_formKey.currentState!.validate() && _fechaHora != null) {
      _formKey.currentState!.save();

      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await NotificationService.scheduleNotification(
        id: id,
        title: _titulo,
        body: _descripcion,
        dateTime: _fechaHora!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recordatorio creado con éxito')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Recordatorio')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Título'),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Requerido' : null,
                onSaved: (value) => _titulo = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 2,
                onSaved: (value) => _descripcion = value ?? '',
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _fechaHora == null
                          ? 'Selecciona fecha y hora'
                          : _dateFormat.format(_fechaHora!),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _pickDateTime,
                    child: const Text('Elegir'),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _guardarRecordatorio,
                icon: const Icon(Icons.alarm),
                label: const Text('Guardar Recordatorio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
