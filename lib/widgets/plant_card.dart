import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/plant.dart';
import '../models/plants_data.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  final PlantData? enrichedDetails;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    this.enrichedDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: plant.imageUrl.isNotEmpty
              ? Image.network(
                  plant.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : const Icon(Icons.local_florist, size: 40, color: Colors.green),
        ),
        title: Text(
          plant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: enrichedDetails != null && enrichedDetails!.details.isNotEmpty
            ? Text('🌱 Origine : ${enrichedDetails!.details['Origine'] ?? 'Inconnue'}')
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('mesures')
                    .where('plantId', isEqualTo: plant.id)
                    .orderBy('timestamp', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("Chargement des mesures...");
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text("Aucune mesure disponible");
                  }

                  final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                  final temp = data['temperature']?.toStringAsFixed(1) ?? 'N/A';
                  final eau = data['niveau_eau']?.toStringAsFixed(1) ?? 'N/A';

                  return Text("💧 Eau : $eau cm - 🌡️ Temp : $temp °C");
                },
              ),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

