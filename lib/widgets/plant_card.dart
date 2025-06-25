import 'package:flutter/material.dart';
import '../models/plant.dart';
import '../models/plants_data.dart';
import '../models/plants_data.dart'; // Import the file where PlantInfo is defined

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;
  final PlantData? enrichedDetails; // ✅ nouveau champ optionnel

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    this.enrichedDetails, // ✅ constructeur mis à jour
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = enrichedDetails != null
        ? '🌿 ${enrichedDetails!.details['origine'] ?? ''}'
        : '💧 Eau : ${plant.dist} - 🌡️ ${plant.temp}°C';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: plant.imageUrl != null && plant.imageUrl!.isNotEmpty
            ? Image.network(
                plant.imageUrl!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.local_florist, size: 40),
        title: Text(plant.name),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
