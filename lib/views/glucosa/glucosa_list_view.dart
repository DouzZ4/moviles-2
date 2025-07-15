// lib/views/glucosa/glucosa_list_view.dart
// Vista para mostrar el historial de registros de glucosa del usuario en CheckINC.
// Permite ver, refrescar y eliminar registros de glucosa asociados a un usuario.

import 'package:checkinc/views/glucosa/glucosa_form_view.dart'
    show GlucosaFormView;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';

class GlucosaListView extends StatelessWidget {
  /// ID del usuario cuyos registros se mostrarán
  final String idUsuario;

  /// Constructor requiere el idUsuario
  const GlucosaListView({super.key, required this.idUsuario});

  String _formatearFechaHora(DateTime fecha) {
    final f =
        '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
    final h =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    return '$f $h';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Glucosa')),
      body: Consumer<GlucosaViewModel>(
        builder: (context, viewModel, child) {
          // Muestra indicador de carga si está cargando
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Muestra error si existe
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }

          // Muestra mensaje si no hay registros
          if (viewModel.registros.isEmpty) {
            return const Center(child: Text('No hay registros disponibles.'));
          }

          // Lista de registros con opción de refrescar
          return RefreshIndicator(
            onRefresh: () => viewModel.cargarRegistros(idUsuario),
            child: ListView.builder(
              itemCount: viewModel.registros.length,
              itemBuilder: (context, index) {
                final registro = viewModel.registros[index];
                return ListTile(
                  leading: const Icon(Icons.bloodtype, color: Colors.redAccent),
                  title: Text('Nivel: ${registro.nivel} mg/dL'),
                  subtitle: Text(
                    '${_formatearFechaHora(registro.fecha)} • ${registro.momento}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => GlucosaFormView(
                                    idUsuario: registro.idUsuario,
                                    registroExistente: registro,
                                  ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed:
                            () => _confirmarEliminacion(
                              context,
                              viewModel,
                              registro.id,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      // Botón para agregar nuevo registro
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushNamed(
              context,
              '/glucosa/formulario',
              arguments: idUsuario,
            ),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar un registro
  void _confirmarEliminacion(
    BuildContext context,
    GlucosaViewModel viewModel,
    String id,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
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
