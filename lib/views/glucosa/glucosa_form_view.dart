import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkinc/models/glucosa_model.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';

class GlucosaFormView extends StatefulWidget {
  final String idUsuario;

  final GlucosaModel? registroExistente;

  const GlucosaFormView({
    super.key,
    required this.idUsuario,
    this.registroExistente,
  });

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
        id: widget.registroExistente?.id ?? '',
        idUsuario: widget.idUsuario,
        nivel: double.tryParse(_nivelController.text.trim()) ?? 0.0,
        fecha: fechaConHora,
        momento: _momentoController.text.trim(),
      );

      final glucosaVM = Provider.of<GlucosaViewModel>(context, listen: false);
      if (widget.registroExistente != null) {
        // Actualizar registro existente
        await glucosaVM.actualizarRegistro(nuevo);
      } else {
        // Agregar nuevo registro
        await glucosaVM.agregarRegistro(nuevo);
      }
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

  void initState() {
    super.initState();
    if (widget.registroExistente != null) {
      final registro = widget.registroExistente!;
      _nivelController.text = registro.nivel.toString();
      _fechaSeleccionada = registro.fecha;
      _fechaController.text = _formatearFecha(registro.fecha);
      _horaSeleccionada = TimeOfDay.fromDateTime(registro.fecha);
      _horaController.text = _formatearHora(_horaSeleccionada!);
      _momentoController.text = registro.momento;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.registroExistente == null
              ? 'Nuevo Registro de Glucosa'
              : 'Editar Registro',
        ),
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
                      Text(
                        widget.registroExistente == null
                            ? 'Agregar Registro'
                            : 'Editar Registro',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3058a6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completa los datos para guardar tu registro de glucosa.',
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nivelController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Nivel de glucosa',
                          prefixIcon: const Icon(
                            Icons.bloodtype,
                            color: Colors.redAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _fechaController,
                        readOnly: true,
                        onTap: () => _seleccionarFecha(context),
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF3058a6),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ej: 2025-07-02',
                        ),
                        validator: (value) {
                          if (_fechaSeleccionada == null) {
                            return 'Seleccione una fecha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _horaController,
                        readOnly: true,
                        onTap: () => _seleccionarHora(context),
                        decoration: InputDecoration(
                          labelText: 'Hora',
                          prefixIcon: const Icon(
                            Icons.access_time,
                            color: Color(0xFF3058a6),
                          ),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _momentoController,
                        decoration: InputDecoration(
                          labelText: 'Momento del día (ej. ayunas)',
                          prefixIcon: const Icon(
                            Icons.wb_sunny,
                            color: Color(0xFFf45501),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Ingrese el momento'
                                    : null,
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFf45501),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          widget.registroExistente == null
                              ? 'Guardar Registro'
                              : 'Actualizar Registro',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
