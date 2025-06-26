import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SoinsParPlanteChart extends StatelessWidget {
  final Map<String, int> soinsParPlante;

  const SoinsParPlanteChart({
    super.key,
    required this.soinsParPlante,
  });

  @override
  Widget build(BuildContext context) {
    final barGroups = soinsParPlante.entries.toList();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            "Nombre de soins par plante",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.2,
            child: BarChart(
              BarChartData(
                barGroups: List.generate(barGroups.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: barGroups[index].value.toDouble(),
                        color: Colors.orange,
                        width: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, _) {
                        if (value < 0 || value >= barGroups.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(barGroups[value.toInt()].key),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
