import 'package:flutter/material.dart';

class DevicesScreen extends StatelessWidget {
  // Exemple de liste d'appareils (à remplacer par tes données réelles)
  final List<Map<String, dynamic>> devices = const [
    {
      "name": "Capteur Humidité",
      "status": "Connecté",
      "icon": Icons.water_drop,
    },
    {
      "name": "Thermomètre",
      "status": "Déconnecté",
      "icon": Icons.thermostat,
    },
    {
      "name": "Lumière LED",
      "status": "Connecté",
      "icon": Icons.lightbulb,
    },
  ];

  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appareils connectés'),
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(
                device['icon'],
                color: device['status'] == "Connecté" ? Colors.green : Colors.grey,
                size: 32,
              ),
              title: Text(device['name']),
              subtitle: Text('Statut : ${device['status']}'),
              trailing: device['status'] == "Connecté"
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : const Icon(Icons.cancel, color: Colors.red),
              onTap: () {
                // Action à effectuer lors du clic sur un appareil
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${device['name']} sélectionné')),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
