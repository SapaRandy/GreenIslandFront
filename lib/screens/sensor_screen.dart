import 'package:flutter/material.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensors = [
      {'name': 'Capteur Salon', 'status': 'Connecté'},
      {'name': 'Capteur Cuisine', 'status': 'Déconnecté'},
      {'name': 'Capteur Chambre', 'status': 'En attente'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Capteurs connectés"),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sensors.length,
        itemBuilder: (context, index) {
          final sensor = sensors[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                Icons.sensors,
                color: _getStatusColor(sensor['status']!),
              ),
              title: Text(sensor['name']!),
              subtitle: Text('Statut : ${sensor['status']}'),
              trailing: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // TODO: Aller aux paramètres du capteur
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Connecté':
        return Colors.green;
      case 'Déconnecté':
        return Colors.red;
      case 'En attente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}