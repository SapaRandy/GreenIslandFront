import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'plant_detail_screen.dart';
import '../models/plant.dart';
import '../models/plants_data.dart';
import '../widgets/plant_card.dart';



class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text("🌿 Mes Plantes"),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Rechercher une plante...",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // ✅ Graphique des soins
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
          ),

          // 🌿 Liste dynamique des plantes
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('plants')
                  .where('uid', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Erreur de chargement"));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final plantDocs = snapshot.data?.docs ?? [];
                final filteredDocs = plantDocs.where((doc) {
                  final name = (doc['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text("Aucune plante trouvée."));
                }

                return ListView.builder(
                  itemCount: plantDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, index) {
                    final data = plantDocs[index].data() as Map<String, dynamic>;
                    final plant = Plant.fromMap(data, plantDocs[index].id);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('plant_data')
                          .doc(plant.name.toLowerCase().trim()) // nom = clé
                          .get(),
                      builder: (context, snapshot) {
                        PlantData? enriched;

                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data!.exists) {
                          final docData = snapshot.data!.data() as Map<String, dynamic>;
                          enriched = PlantData.fromJson(docData);
                        }

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
                                ),
                              ),
                            );
                          },
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
