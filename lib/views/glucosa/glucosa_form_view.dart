import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkinc/models/glucosa_model.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';

class GlucosaFormView extends StatefulWidget {
  final String idUsuario;

  const GlucosaFormView({super.key, required this.idUsuario});

  @override
  State<GlucosaFormView> createState() => _GlucosaFormViewState();
}

class _GlucosaFormViewState extends State<GlucosaFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nivelController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaController = TextEditingController();
  final TextEditingController _momentoController = TextEditingController();

  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  @override
  void dispose() {
    _nivelController.dispose();
    _fechaController.dispose();
    _horaController.dispose();
    _momentoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', ''),
    );

    if (fechaElegida != null) {
      setState(() {
        _fechaSeleccionada = fechaElegida;
        _fechaController.text = _formatearFecha(fechaElegida);
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? horaElegida = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horaElegida != null) {
      setState(() {
        _horaSeleccionada = horaElegida;
        _horaController.text = _formatearHora(horaElegida);
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    return "${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}";
  }

  String _formatearHora(TimeOfDay hora) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, hora.hour, hora.minute);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _guardar() async {
    if (_formKey.currentState!.validate()) {
      // Combinar fecha + hora
      final fechaConHora = DateTime(
        _fechaSeleccionada!.year,
        _fechaSeleccionada!.month,
        _fechaSeleccionada!.day,
        _horaSeleccionada!.hour,
        _horaSeleccionada!.minute,
      );

      final nuevo = GlucosaModel(
        id: '',
        idUsuario: widget.idUsuario,
        nivel: double.tryParse(_nivelController.text.trim()) ?? 0.0,
        fecha: fechaConHora,
        momento: _momentoController.text.trim(),
      );

      final glucosaVM = Provider.of<GlucosaViewModel>(context, listen: false);
      await glucosaVM.agregarRegistro(nuevo);

      if (glucosaVM.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro guardado correctamente')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${glucosaVM.error}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Registro de Glucosa'),
        backgroundColor: const Color(0xFF3058a6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nivelController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nivel de glucosa',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un valor';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Debe ser un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                onTap: () => _seleccionarFecha(context),
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 2025-07-02',
                ),
                validator: (value) {
                  if (_fechaSeleccionada == null) {
                    return 'Seleccione una fecha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horaController,
                readOnly: true,
                onTap: () => _seleccionarHora(context),
                decoration: const InputDecoration(
                  labelText: 'Hora',
                  border: OutlineInputBorder(),
                  hintText: 'Ej: 08:30',
                ),
                validator: (value) {
                  if (_horaSeleccionada == null) {
                    return 'Seleccione una hora';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _momentoController,
                decoration: const InputDecoration(
                  labelText: 'Momento del día (ej. ayunas)',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Ingrese el momento'
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf45501),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Guardar Registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
