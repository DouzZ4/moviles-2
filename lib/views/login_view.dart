// login_view.dart
// Vista de inicio de sesión para la app CheckINC.
// Permite al usuario autenticarse con su nombre de usuario y contraseña.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkinc/viewmodels/usuario_viewmodel.dart';
import 'package:checkinc/models/usuario_model.dart';
import 'dashboard_view.dart';
import 'register_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Controladores para los campos del formulario
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _documentoController = TextEditingController();
  final _contrasenaController = TextEditingController();

  @override
  void dispose() {
    // Libera los controladores al destruir la vista
    _usernameController.dispose();
    _documentoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  /// Lógica para iniciar sesión
  void _iniciarSesion() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final contrasena = _contrasenaController.text.trim();
      final vm = Provider.of<UsuarioViewModel>(context, listen: false);
      await vm.cargarUsuariosDesdeLocal();
      final usuario = vm.obtenerPorUsernameYContrasena(username, contrasena);
      if (usuario != null) {
        _mostrarMensaje('Bienvenido, ${usuario.nombres}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DashboardView(usuario: usuario)),
        );
      } else {
        _mostrarMensaje('Usuario o contraseña incorrectos');
      }
    }
  }

  /// Muestra un mensaje en un SnackBar
  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: const Color(0xFF3058a6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Campo de usuario
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Ingrese el usuario' : null,
              ),
              const SizedBox(height: 16),
              // Campo de contraseña
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
              const SizedBox(height: 24),
              // Botón para iniciar sesión
              ElevatedButton(
                onPressed: _iniciarSesion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf45501),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ingresar'),
              ),
              const SizedBox(height: 12),
              // Botón para ir a la pantalla de registro
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterView()),
                  );
                },
                child: const Text('¿No tienes cuenta? Regístrate aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
