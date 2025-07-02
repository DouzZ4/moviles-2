// lib/views/register_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkinc/viewmodels/usuario_viewmodel.dart';
import 'package:checkinc/models/usuario_model.dart';
import 'package:uuid/uuid.dart';
import 'dashboard_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _edadController = TextEditingController();
  final _correoController = TextEditingController();
  final _usernameController = TextEditingController();
  final _documentoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _edadController.dispose();
    _correoController.dispose();
    _usernameController.dispose();
    _documentoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  void _registrar() async {
    if (_formKey.currentState!.validate()) {
      final usuario = UsuarioModel(
        id: const Uuid().v4(),
        nombres: _nombresController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        edad: int.parse(_edadController.text.trim()),
        correo: _correoController.text.trim(),
        username: _usernameController.text.trim(),
        documento: int.parse(_documentoController.text.trim()),
        contrasena: _contrasenaController.text.trim(),
      );

      final vm = Provider.of<UsuarioViewModel>(context, listen: false);
      await vm.agregarUsuario(usuario);

      if (vm.error == null) {
        _mostrarMensaje('¡Registro exitoso!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardView(usuario: usuario)),
        );
      } else {
        _mostrarMensaje('Error: ${vm.error}');
      }
    }
  }

  void _mostrarMensaje(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Usuario'),
        backgroundColor: const Color(0xFF3058a6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _inputField(_nombresController, 'Nombres'),
              const SizedBox(height: 12),
              _inputField(_apellidosController, 'Apellidos'),
              const SizedBox(height: 12),
              _inputField(_edadController, 'Edad', tipo: TextInputType.number),
              const SizedBox(height: 12),
              _inputField(_correoController, 'Correo', tipo: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _inputField(_usernameController, 'Nombre de Usuario'),
              const SizedBox(height: 12),
              _inputField(_documentoController, 'Documento', tipo: TextInputType.number),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese la contraseña' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf45501),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController controller, String label,
      {TextInputType tipo = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ingrese $label' : null,
    );
  }
}
