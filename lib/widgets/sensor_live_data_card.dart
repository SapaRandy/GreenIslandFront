import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SensorLiveDataCard extends StatelessWidget {
  final String plantId;
  final String sensorType; // "temperature", "humidity", "waterlevel"

  const SensorLiveDataCard({
    super.key,
    required this.plantId,
    required this.sensorType,
  });

  @override
  Widget build(BuildContext context) {
    final sensorCollection = "${sensorType}_data";

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(sensorCollection)
          .where('plantId', isEqualTo: plantId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text("Aucune donnée pour $sensorType");
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final value = data['value'];
        final time = (data['timestamp'] as Timestamp).toDate();

        return Card(
          child: ListTile(
            title: Text("$sensorType: $value"),
            subtitle: Text("Mis à jour : ${time.toLocal()}"),
          ),
        );
      },
    );
  }
}
