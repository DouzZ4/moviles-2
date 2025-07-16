// lib/views/glucosa/glucosa_list_view.dart
// Vista para mostrar el historial de registros de glucosa del usuario en CheckINC.
// Permite ver, refrescar y eliminar registros de glucosa asociados a un usuario.

import 'package:checkinc/views/glucosa/glucosa_form_view.dart'
    show GlucosaFormView;
import 'package:checkinc/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';

class GlucosaListView extends StatefulWidget {
  /// ID del usuario cuyos registros se mostrarán
  final String idUsuario;

  /// Constructor requiere el idUsuario
  const GlucosaListView({super.key, required this.idUsuario});

  @override
  State<GlucosaListView> createState() => _GlucosaListViewState();
}

class _GlucosaListViewState extends State<GlucosaListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<GlucosaViewModel>(context, listen: false);
      viewModel.importarDesdeFirestore();
      viewModel.cargarRegistrosLocal(widget.idUsuario);
    });
  }

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
            onRefresh: () async {
              await viewModel.importarDesdeFirestore();
              await viewModel.cargarRegistrosLocal(widget.idUsuario);
              await viewModel.sincronizarDatos();
            },
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
                        icon: const Icon(
                          Icons.notifications_active,
                          color: Colors.orange,
                        ),
                        tooltip: 'Programar recordatorio',
                        onPressed: () async {
                          // Programa una notificación para el registro actual (ejemplo: 24h después)
                          final fechaNotificacion = registro.fecha.add(
                            const Duration(hours: 24),
                          );
                          await NotificationService.scheduleNotification(
                            id: registro.id.hashCode,
                            title: 'Recordatorio de glucosa',
                            body:
                                'Recuerda registrar tu nivel de glucosa nuevamente.',
                            dateTime: fechaNotificacion,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notificación programada para 24h después de este registro.',
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
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_off,
                          color: Colors.grey,
                        ),
                        tooltip: 'Cancelar recordatorio',
                        onPressed: () async {
                          await NotificationService.cancelNotification(
                            registro.id.hashCode,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notificación cancelada para este registro.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.pushNamed(
              context,
              '/glucosa/formulario',
              arguments: widget.idUsuario,
            ),
        child: const Icon(Icons.add),
      ),
    );
  }

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
