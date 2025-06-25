import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/plant.dart';
import '../models/plants_data.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;
  final String initialImageUrl;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    required this.initialImageUrl,
  });

  Future<Plant?> fetchPlant() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('plants').doc(plantId).get();
      if (doc.exists) {
        return Plant.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint("Erreur chargement plante: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la plante"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Plant?>(
        future: fetchPlant(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Plante introuvable"));
          }

          final plant = snapshot.data!;
          final enriched = plantsData.firstWhere(
            (p) => p.name.toLowerCase() == plant.name.toLowerCase(),
            orElse: () => PlantData(name: '', details: {}),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (plant.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      plant.imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                Text(plant.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Créée le: ${DateFormat('dd MMM yyyy').format(plant.createdAt)}"),
                const Divider(height: 24),

                Row(
                  children: [
                    _buildBadge("💧 Eau", plant.dist),
                    const SizedBox(width: 12),
                    _buildBadge("🌡 Temp", "${plant.temp} °C"),
                    const SizedBox(width: 12),
                    _buildBadge("💦 Humidité", "${plant.humidity} %"),
                  ],
                ),

                const SizedBox(height: 24),
                if (enriched.details.isNotEmpty) ...[
                  const Text("📘 Informations botaniques :", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...enriched.details.entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("• ", style: TextStyle(fontSize: 16)),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: "${e.key} : ",
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: e.value),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else
                  const Text("Pas de données botaniques enrichies disponibles.", style: TextStyle(fontStyle: FontStyle.italic)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text("$label : $value", style: const TextStyle(fontSize: 14)),
    );
  }
}