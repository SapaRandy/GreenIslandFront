import 'package:flutter/material.dart';
import 'plant_detail_screen.dart';
import 'add_plant_screen.dart';
import '../widgets/plant_card.dart';
import '../models/plant.dart';


class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> plants = const [
    {"name": "Basilic", "humidity": "45%", "temp": "25°C"},
    {"name": "Aloe Vera", "humidity": "60%", "temp": "22°C"},
  ];

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mes plantes")),
      body: ListView.builder(
        itemCount: plants.length,
        itemBuilder: (context, index) {
          return PlantCard(
            plant: Plant.fromMap(plants[index]),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => PlantDetailScreen(
                  plantName: plants[index]['name'] ?? '',
                  room: 'Salon', // à remplacer si tu as cette info ailleurs
                  imageUrl: 'https://via.placeholder.com/150', // à personnaliser
                ),
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddPlantScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
