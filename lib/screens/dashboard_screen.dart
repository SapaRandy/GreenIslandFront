import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'plant_detail_screen.dart';
import 'add_plant_screen.dart' as add_plant;
import 'sensor_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _addPlant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const add_plant.AddPlantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Plantes"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('plants')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("Aucune plante ajoutée."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final plant = docs[index].data() as Map<String, dynamic>;
              final id = docs[index].id;

              return _buildPlantCard(
                context,
                id: id,
                name: plant['name'] ?? 'Nom inconnu',
                dist: plant['dist'] ?? 'Non précisé',
                humidity: plant['humidity'] ?? '--',
                temp: plant['temp'] ?? '--',
                imageUrl: plant['imageUrl'] ?? '',
                createdAt: plant['createdAt'] as Timestamp?,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => _addPlant(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.green,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Capteurs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SensorsScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildPlantCard(
    BuildContext context, {
    required String id,
    required String name,
    required String dist,
    required String humidity,
    required String temp,
    required String imageUrl,
    Timestamp? createdAt,
  }) {
    final date = createdAt != null
        ? DateTime.fromMillisecondsSinceEpoch(createdAt.millisecondsSinceEpoch)
        : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageUrl.isNotEmpty
              ? Image.network(
                  '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) =>
                      const Icon(Icons.image_not_supported),
                )
              : const Icon(Icons.image, size: 60),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Niveau eau : $dist"),
            Text("Humidité : $humidity"),
            Text("Température : $temp"),
            if (date != null)
              Text("Ajoutée le : ${date.day}/${date.month}/${date.year}"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  PlantDetailScreen(plantId: id, initialImageUrl: imageUrl),
            ),
          );
        },
      ),
    );
  }
}
