import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PlantCareChart extends StatefulWidget {
  const PlantCareChart({super.key});

  @override
  State<PlantCareChart> createState() => _PlantCareChartState();
}

class _PlantCareChartState extends State<PlantCareChart> {
  Map<String, int> _careCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCareCounts();
  }

  Future<void> _fetchCareCounts() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('plants')
        .where('userId', isEqualTo: uid)
        .get();

    Map<String, int> counts = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final name = data['name'] ?? 'Inconnu';
      final careLogs = data['careLogs'] ?? [];

      if (careLogs is List) {
        counts[name] = careLogs.length;
      } else {
        counts[name] = 0;
      }
    }

    setState(() {
      _careCounts = counts;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_careCounts.isEmpty) {
      return const Center(child: Text("Aucun soin enregistré pour vos plantes."));
    }

    final barGroups = _careCounts.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final mapEntry = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: mapEntry.value.toDouble(),
            color: Colors.orange,
            width: 22,
          )
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Nombre de soins par plante",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= _careCounts.length) return const SizedBox.shrink();
                        final label = _careCounts.keys.elementAt(index);
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(label, style: const TextStyle(fontSize: 10)),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
