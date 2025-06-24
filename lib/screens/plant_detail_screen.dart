import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;
  final String initialImageUrl;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    required this.initialImageUrl,
  });

  void _deletePlant(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Supprimer cette plante ?"),
        content: const Text("Cette action est irréversible."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuler"),
          ),
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
        await FirebaseFirestore.instance
            .collection('plants')
            .doc(plantId)
            .delete();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Plante supprimée avec succès.")),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
      }
    }
  }

  Future<void> _addCareLog(BuildContext context, String action) async {
    try {
      final log = {'action': action, 'date': DateTime.now().toIso8601String()};
      await FirebaseFirestore.instance.collection('plants').doc(plantId).update(
        {
          'careLogs': FieldValue.arrayUnion([log]),
        },
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$action ajouté à l’historique')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur ajout soin : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail de la plante"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePlant(context),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('plants')
            .doc(plantId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Plante non trouvée"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String name = data['name'] ?? 'Nom inconnu';
          final String dist = data['dist'] ?? '-';
          final String humidity = data['humidity'] ?? '-';
          final String temp = data['temp'] ?? '-';
          final String imageUrl = data['imageUrl'] ?? '';
          final double? latitude = data['latitude'] is double
              ? data['latitude']
              : null;
          final double? longitude = data['longitude'] is double
              ? data['longitude']
              : null;

          final List<dynamic> careLogsRaw = data['careLogs'] ?? [];
          final List<Map<String, dynamic>> careLogs = careLogsRaw
              .whereType<Map<String, dynamic>>()
              .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(
                  imageUrl.isNotEmpty
                      ? '$imageUrl?t=${DateTime.now().millisecondsSinceEpoch}'
                      : 'https://via.placeholder.com/150?text=Plante',
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Niveau eau : $dist"),
                      Text("Température : $temp°C"),
                      Text("Humidité : $humidity%"),
                      const SizedBox(height: 12),

                      if (latitude != null && longitude != null)
                        SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(latitude, longitude),
                              zoom: 16,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('plant_location'),
                                position: LatLng(latitude, longitude),
                                infoWindow: InfoWindow(title: name),
                              ),
                            },
                            myLocationEnabled: false,
                            zoomControlsEnabled: false,
                          ),
                        )
                      else
                        Row(
                          children: const [
                            Icon(Icons.location_off, color: Colors.grey),
                            SizedBox(width: 6),
                            Text("Localisation non disponible"),
                          ],
                        ),

                      const SizedBox(height: 24),
                      const Text(
                        "Historique des soins :",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (careLogs.isEmpty)
                        const Text("Aucun soin enregistré.")
                      else
                        ...careLogs.map((log) {
                          final action = log['action'] ?? 'Action inconnue';
                          final date = log['date'] ?? '';
                          return ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(action),
                            subtitle: Text(date.toString()),
                          );
                        }),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _addCareLog(context, "Arrosage"),
                            icon: const Icon(Icons.water_drop),
                            label: const Text("Arroser"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () =>
                                _addCareLog(context, "Fertilisation"),
                            icon: const Icon(Icons.eco),
                            label: const Text("Fertiliser"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
