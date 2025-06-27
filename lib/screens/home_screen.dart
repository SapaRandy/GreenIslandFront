import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'plant_detail_screen.dart';
import 'add_plant_screen.dart' as add_plant;
import 'profile_screen.dart';
import '../models/plant.dart';
import '../models/plants_data.dart'; // Import des données enrichies
import '../widgets/plant_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("🌿 Mes Plantes"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Actions rapides
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.water_drop_outlined),
                    label: const Text("Tout arroser"),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Arrosage en cours...")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const add_plant.AddPlantScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 59, 129, 49),
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('plants')
                  .where('uid', isEqualTo: userId) // 🔥 Ajout du filtre utilisateur
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final plantDocs = snapshot.data?.docs ?? [];

                if (plantDocs.isEmpty) {
                  return const Center(
                    child: Text("Aucune plante enregistrée."),
                  );
                }

                return ListView.builder(
                  itemCount: plantDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final data = plantDocs[index].data() as Map<String, dynamic>;
                    final plant = Plant.fromMap(data, plantDocs[index].id);

                    final enriched = plantsData.firstWhere(
                      (p) => p.name.trim().toLowerCase() == plant.name.trim().toLowerCase(),
                      orElse: () => PlantData(name: '', details: {}),
                    );

                    return PlantCard(
                      plant: plant,
                      enrichedDetails: enriched,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlantDetailScreen(
                              plant: plant,
                              plantId: plant.id,
                              // initialImageUrl: plant.imageUrl, // Removed because it's not defined
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}
