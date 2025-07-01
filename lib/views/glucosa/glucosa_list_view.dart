// lib/views/glucosa/glucosa_list_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';
import 'package:checkinc/models/glucosa_model.dart';

class GlucosaListView extends StatelessWidget {
  final String idUsuario;

  const GlucosaListView({super.key, required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Glucosa'),
      ),
      body: Consumer<GlucosaViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }

          if (viewModel.registros.isEmpty) {
            return const Center(child: Text('No hay registros disponibles.'));
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.cargarRegistros(idUsuario),
            child: ListView.builder(
              itemCount: viewModel.registros.length,
              itemBuilder: (context, index) {
                final registro = viewModel.registros[index];
                return ListTile(
                  leading: const Icon(Icons.bloodtype, color: Colors.redAccent),
                  title: Text('Nivel: ${registro.nivel} mg/dL'),
                  subtitle: Text('${registro.fecha} • ${registro.momento}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmarEliminacion(context, viewModel, registro.id!),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/glucosa/formulario', arguments: idUsuario),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmarEliminacion(BuildContext context, GlucosaViewModel viewModel, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Registro'),
        content: const Text('¿Estás seguro de eliminar este registro?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: const Text('Eliminar'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await viewModel.eliminarRegistro(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Registro eliminado')),
              );
            },
          ),
        ],
      ),
    );
  }
}
