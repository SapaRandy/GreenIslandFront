import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;
  final String plantName;
  final String room;
  final String imageUrl;
  final String humidity;
  final String temp;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    required this.plantName,
    required this.room,
    required this.imageUrl,
    required this.humidity,
    required this.temp,
  });

  void _deletePlant(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer cette plante ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Annuler")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Supprimer"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('plants').doc(plantId).delete();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plante supprimée avec succès.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.toString()}")),
        );
      }
    }
  }

  void _editPlant(BuildContext context) {
    // TODO: Naviguer vers un écran d’édition avec les valeurs actuelles
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Édition non encore implémentée.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(plantName),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPlant(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePlant(context),
          ),
        ],
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
                const SizedBox(height: 8),
                Text("Température actuelle : $temp", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Humidité : $humidity", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                const Text("Dernier arrosage : il y a 3 jours"),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// This file defines the PlantDetailScreen widget, which displays detailed information about a specific plant.
// It includes options to edit or delete the plant, and shows its image, name, room, humidity, and temperature.