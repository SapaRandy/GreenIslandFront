import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantName;
  final String room;
  final String imageUrl;

  const PlantDetailScreen({
    super.key,
    required this.plantName,
    required this.room,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantName),
        backgroundColor: Colors.green,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            imageUrl,
            height: 250,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plantName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text("Pièce : $room", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                const Text("Dernier arrosage : il y a 3 jours"),
                const SizedBox(height: 8),
                const Text("Température actuelle : 22°C"),
                const SizedBox(height: 8),
                const Text("Humidité : 60%"),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.water_drop),
                      label: const Text("Arroser"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.eco),
                      label: const Text("Fertiliser"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
