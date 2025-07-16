import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:checkinc/viewmodels/glucosa_viewmodel.dart';

class GlucosaBarChart extends StatelessWidget {
  final String idUsuario;
  const GlucosaBarChart({super.key, required this.idUsuario});

  @override
  Widget build(BuildContext context) {
    return Consumer<GlucosaViewModel>(
      builder: (context, viewModel, child) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final lastWeek = today.subtract(const Duration(days: 6));

        final registrosSemana =
            viewModel.registros
                .where(
                  (r) =>
                      r.idUsuario == idUsuario &&
                      r.fecha.isAfter(
                        lastWeek.subtract(const Duration(days: 1)),
                      ),
                )
                .toList();

        final List<DateTime> dias = List.generate(
          7,
          (i) => lastWeek.add(Duration(days: i)),
        );

        final List<List<double>> glucosaPorDia = List.generate(7, (_) => []);
        for (var registro in registrosSemana) {
          final registroDia = DateTime(
            registro.fecha.year,
            registro.fecha.month,
            registro.fecha.day,
          );
          for (int i = 0; i < 7; i++) {
            if (registroDia == dias[i]) {
              glucosaPorDia[i].add(registro.nivel);
              break;
            }
          }
        }

        final List<double> promedios = List.generate(7, (i) {
          final valores = glucosaPorDia[i];
          if (valores.isEmpty) return 0;
          return valores.reduce((a, b) => a + b) / valores.length;
        });

        return SizedBox(
          height: 280,
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Reporte semanal de glucosa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3058a6), // azul institucional
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 250,
                        minY: 0,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                'Nivel: ${rod.toY.toStringAsFixed(1)}',
                                const TextStyle(color: Colors.white),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                if (value % 50 != 0) return const SizedBox();
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() < 0 || value.toInt() > 6) {
                                  return const SizedBox();
                                }
                                final fecha = dias[value.toInt()];
                                final texto =
                                    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}';
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Text(
                                    texto,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              },
                              reservedSize: 42,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          horizontalInterval: 50,
                          getDrawingHorizontalLine:
                              (value) => FlLine(
                                color: Colors.grey[300],
                                strokeWidth: 1,
                              ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(7, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: promedios[i],
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF3058a6), // azul
                                    const Color(0xFFf45501), // naranja
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                width: 20,
                                borderRadius: BorderRadius.circular(8),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: 250,
                                  color: Colors.grey[200],
                                ),
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
