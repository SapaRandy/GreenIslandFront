import 'package:flutter/material.dart';
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
    final subtitle = enrichedDetails != null && enrichedDetails!.details.isNotEmpty
        ? '🌱 Origine : ${enrichedDetails!.details['Origine'] ?? 'Inconnue'}'
        : '💧 Eau : ${plant.dist} - 🌡️ Temp : ${plant.temp}°C';

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
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
