import 'package:flutter/material.dart';

class PlantCard extends StatelessWidget {
  final Map<String, String> plant;
  final VoidCallback onTap;

  const PlantCard({super.key, required this.plant, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(plant["name"] ?? ""),
        subtitle: Text("Humidité : ${plant["humidity"]} | Température : ${plant["temp"]}"),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
