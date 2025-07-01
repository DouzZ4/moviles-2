import 'package:checkinc/models/usuario_model.dart';
import 'package:flutter/material.dart';
import 'package:checkinc/views/glucosa/glucosa_list_view.dart';
import 'package:checkinc/views/glucosa/glucosa_form_view.dart';

class DashboardView extends StatelessWidget {
final UsuarioModel usuario;

const DashboardView({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Usuario'),
        backgroundColor: const Color(0xFF3058a6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bienvenido a CheckINC',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.list, color: Color(0xFF3058a6)),
                title: const Text('Ver Registros de Glucosa'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GlucosaListView(idUsuario: usuario.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.add, color: Color(0xFFf45501)),
                title: const Text('Agregar Registro de Glucosa'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GlucosaFormView(idUsuario: usuario.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Aquí puedes agregar más módulos
          ],
        ),
      ),
    );
  }
}
