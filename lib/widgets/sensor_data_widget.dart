import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SensorDataWidget extends StatelessWidget {
  final String plantDocId;

  const SensorDataWidget({super.key, required this.plantDocId});

  Stream<Map<String, String>> _sensorStream() async* {
    while (true) {
      final tempSnap = await FirebaseFirestore.instance
          .collection('sensor_temperature')
          .where('plantId', isEqualTo: 'plants/$plantDocId')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final humiditySnap = await FirebaseFirestore.instance
          .collection('sensor_humidity')
          .where('plantId', isEqualTo: 'plants/$plantDocId')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final distSnap = await FirebaseFirestore.instance
          .collection('sensor_distance')
          .where('plantId', isEqualTo: 'plants/$plantDocId')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      yield {
        'Température': tempSnap.docs.isNotEmpty ? tempSnap.docs.first['value'].toString() : 'N/A',
        'Humidité': humiditySnap.docs.isNotEmpty ? humiditySnap.docs.first['value'].toString() : 'N/A',
        'Distance': distSnap.docs.isNotEmpty ? distSnap.docs.first['value'].toString() : 'N/A',
      };

      await Future.delayed(const Duration(seconds: 10)); // refresh toutes les 10s
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, String>>(
      stream: _sensorStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🔍 Données en temps réel", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("🌡️ Température : ${data['Température']}°C"),
            Text("💧 Humidité : ${data['Humidité']}%"),
            Text("📏 Distance : ${data['Distance']} cm"),
          ],
        );
      },
    );
  }
}
