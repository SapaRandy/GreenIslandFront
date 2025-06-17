import 'package:flutter/material.dart';
import 'plant_detail_screen.dart';
import 'add_plant_screen.dart';
import '../widgets/plant_card.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> plants = [
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
            plant: plants[index],
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => PlantDetailScreen(plant: plants[index]),
              ));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddPlantScreen()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
