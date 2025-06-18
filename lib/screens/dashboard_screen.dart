import 'package:flutter/material.dart';
import 'plant_detail_screen.dart';
import 'add_plant_screen.dart';
import 'sensor_screen.dart';
import 'profile_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _addPlant(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPlantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes plantes"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlantCard(
            context,
            name: "Monstera",
            room: "Salon",
            imageUrl: "https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2",
          ),
          _buildPlantCard(
            context,
            name: "Ficus",
            room: "Chambre",
            imageUrl: "https://images.unsplash.com/photo-1616627982501-0d7f2562f291",
          ),
          _buildPlantCard(
            context,
            name: "Aloe Vera",
            room: "Cuisine",
            imageUrl: "https://images.unsplash.com/photo-1587301023694-30f0d1dfd93e",
          ),
        ],
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
}

      ),
    );
  }

  Widget _buildPlantCard(BuildContext context, {
    required String name,
    required String room,
    required String imageUrl,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Pièce : $room"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlantDetailScreen(
                plantId: name.hashCode.toString(), // or provide a real plantId
                plantName: name,
                room: room,
                imageUrl: imageUrl,
                humidity: 50.toString(), // replace with actual humidity value if available
                temp: 22.toString(), // replace with actual temperature value if available
              ),
            ),
          );
        },
      ),
    );
  }
}
