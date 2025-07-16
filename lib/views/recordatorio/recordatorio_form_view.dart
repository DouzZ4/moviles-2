import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:checkinc/services/notification_service.dart';

class RecordatorioFormView extends StatefulWidget {
  const RecordatorioFormView({super.key});

  @override
  State<RecordatorioFormView> createState() => _RecordatorioFormViewState();
}

class _RecordatorioFormViewState extends State<RecordatorioFormView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('es', ''),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(fecha);
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? hora = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (hora != null) {
      setState(() {
        _horaSeleccionada = hora;
        final ahora = DateTime.now();
        final dt = DateTime(
          ahora.year,
          ahora.month,
          ahora.day,
          hora.hour,
          hora.minute,
        );
        _horaController.text = DateFormat('HH:mm').format(dt);
      });
    }
  }

  Future<void> _guardar() async {
    if (_formKey.currentState!.validate()) {
      final fechaHora = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await NotificationService.scheduleNotification(
        id: id,
        title: _tituloController.text.trim(),
        body: _descripcionController.text.trim(),
        dateTime: fechaHora,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Recordatorio creado con éxito')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Recordatorio'),
        backgroundColor: const Color(0xFF3058a6),
        elevation: 2,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3eafc), Color(0xFFf7f7fa)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Crear Recordatorio',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3058a6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rellena los campos para configurar una notificación.',
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Título
                      TextFormField(
                        controller: _tituloController,
                        decoration: InputDecoration(
                          labelText: 'Título',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Ingrese un título'
                                    : null,
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: _descripcionController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          prefixIcon: const Icon(Icons.notes),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fecha
                      TextFormField(
                        controller: _fechaController,
                        readOnly: true,
                        onTap: () => _seleccionarFecha(context),
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ej: 2025-07-16',
                        ),
                        validator: (value) {
                          if (_fechaSeleccionada == null) {
                            return 'Seleccione una fecha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Hora
                      TextFormField(
                        controller: _horaController,
                        readOnly: true,
                        onTap: () => _seleccionarHora(context),
                        decoration: InputDecoration(
                          labelText: 'Hora',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ej: 08:30',
                        ),
                        validator: (value) {
                          if (_horaSeleccionada == null) {
                            return 'Seleccione una hora';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Botón guardar
                      ElevatedButton.icon(
                        onPressed: _guardar,
                        icon: const Icon(Icons.alarm),
                        label: const Text('Guardar Recordatorio'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFf45501),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
