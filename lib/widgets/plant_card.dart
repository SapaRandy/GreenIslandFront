import 'package:flutter/material.dart';
import '../models/plant.dart';
import 'package:intl/intl.dart' as intl; // Pour formater les dates

class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback onTap;

  const PlantCard({super.key, required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formattedDate = plant.createdAt != null
        ? intl.DateFormat('dd/MM/yyyy').format(plant.createdAt!.toDate())
        : 'Date inconnue';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            plant.imageUrl ?? 'https://source.unsplash.com/featured/?plant',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 60),
          ),
        ),
        title: Text(
          plant.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plant.dist != null && plant.dist!.isNotEmpty)
              Text("Niveau eau : ${plant.dist}"),
            Text("Humidité : ${plant.humidity}"),
            Text("Température : ${plant.temp}"),
            Text("Ajoutée le : $formattedDate"),
            if (plant.latitude != null && plant.longitude != null)
              Text("📍 ${plant.latitude}, ${plant.longitude}"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
