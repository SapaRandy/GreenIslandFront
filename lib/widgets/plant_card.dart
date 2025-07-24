import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/plant.dart';
import '../models/plants_data.dart';

class PlantCard extends StatefulWidget {
  final Plant plant;
  final VoidCallback onTap;
  final PlantData? enrichedDetails;

  const PlantCard({
    Key? key,
    required this.plant,
    required this.onTap,
    this.enrichedDetails,
  }) : super(key: key);

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  late Future<Map<String, dynamic>?> lastMeasureFuture;

  @override
  void initState() {
    super.initState();
    lastMeasureFuture = fetchLastMeasure(widget.plant.id);
  }

  Future<Map<String, dynamic>?> fetchLastMeasure(String plantId) async {
    final url = Uri.parse(
        'https://greenislandback.onrender.com/plantid/mesures/$plantId/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print("Erreur backend: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Erreur réseau: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget subtitleWidget;

    // Si infos enrichies disponibles
    if (widget.enrichedDetails != null &&
        widget.enrichedDetails!.details.isNotEmpty) {
      subtitleWidget = Text(
        '🌱 Origine : ${widget.enrichedDetails!.details['Origine'] ?? 'Inconnue'}',
      );
    } else {
      subtitleWidget = FutureBuilder<Map<String, dynamic>?>(
        future: lastMeasureFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Chargement des mesures...");
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Text("Aucune mesure disponible");
          }

          final data = snapshot.data!;
          final temp = (data['temperature'] is num)
              ? (data['temperature'] as num).toStringAsFixed(1)
              : 'N/A';
          final eau = (data['niveau_eau'] is num)
              ? (data['niveau_eau'] as num).toStringAsFixed(1)
              : 'N/A';
          final hum = (data['humidite'] is num)
              ? (data['humidite'] as num).toStringAsFixed(1)
              : 'N/A';

          return Text("💧 Eau : $eau cm • 🌡️ Temp : $temp °C • 💦 Hum : $hum%");
        },
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.plant.imageUrl.isNotEmpty
              ? Image.network(
                  widget.plant.imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                )
              : const Icon(Icons.local_florist, size: 40, color: Colors.green),
        ),
        title: Text(
          widget.plant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: subtitleWidget,
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: widget.onTap,
      ),
    );
  }
}