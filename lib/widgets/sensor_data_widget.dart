import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SensorDataWidget extends StatelessWidget {
  final String plantId;

  const SensorDataWidget({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mesures')
          .where('plantId', isEqualTo: plantId) // 🔗 Lien direct vers la plante
          .orderBy('timestamp', descending: true) // 🕒 Trie par date
          .limit(1) // 🔁 Récupère la dernière mesure
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("Aucune mesure disponible");
        }

        final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("📈 Données en temps réel", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("🌡️ Température : ${data['temperature'] ?? 'N/A'} °C"),
            Text("💧 Humidité : ${data['humidite'] ?? 'N/A'} %"),
            Text("📏 Niveau eau : ${data['niveau_eau'] ?? 'N/A'} cm"),
            Text("🌍 Pression : ${data['pression'] ?? 'N/A'} hPa"),
            Text("🌱 Humidité sol : ${data['sol'] ?? 'N/A'} %"),
          ],
        );
      },
    );
  }
}
