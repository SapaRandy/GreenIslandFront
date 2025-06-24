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

  void _editPlant(BuildContext context, Map<String, dynamic> data) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: data['name'] ?? '');
    final roomController = TextEditingController(text: data['dist'] ?? '');
    final humidityController = TextEditingController(
      text: data['humidity'] ?? '',
    );
    final tempController = TextEditingController(text: data['temp'] ?? '');
    final imageUrlController = TextEditingController(
      text: data['imageUrl'] ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Modifier la plante",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Nom'),
                    validator: (v) => v!.isEmpty ? "Nom requis" : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: roomController,
                    decoration: const InputDecoration(labelText: 'Niveau eau'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: humidityController,
                    decoration: const InputDecoration(
                      labelText: 'Humidité (%)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: tempController,
                    decoration: const InputDecoration(
                      labelText: 'Température (°C)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text("Enregistrer"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      try {
                        await FirebaseFirestore.instance
                            .collection('plants')
                            .doc(plantId)
                            .update({
                              'name': nameController.text.trim(),
                              'dist': roomController.text.trim(),
                              'humidity': humidityController.text.trim(),
                              'temp': tempController.text.trim(),
                              'imageUrl': imageUrlController.text.trim(),
                            });
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Modifications enregistrées."),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur : ${e.toString()}")),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
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
            icon: const Icon(Icons.edit),
            onPressed: () {}, // sera redéfini après avoir chargé les données
          ),
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
          final imageUrl = data['imageUrl'] ?? '';
          final name = data['name'] ?? 'Nom inconnu';
          final dist = data['dist'] ?? '-';
          final humidity = data['humidity'] ?? '-';
          final temp = data['temp'] ?? '-';
          final latitude = data['latitude'];
          final longitude = data['longitude'];
          final careLogs = (data['careLogs'] ?? []) as List;

          // 🛠 Lier l’action du bouton edit maintenant que data est là
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ModalRoute.of(context)?.isCurrent == true) {
              AppBar? appBar = Scaffold.of(context).widget.appBar as AppBar?;
              appBar?.actions?.removeWhere(
                (a) => a is IconButton && (a.icon as Icon).icon == Icons.edit,
              );
            }
          });

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
                      Text(
                        "Niveau eau : $dist",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Température : $temp°C",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "Humidité : $humidity%",
                        style: const TextStyle(fontSize: 16),
                      ),
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
                            Text(
                              "Localisation non disponible",
                              style: TextStyle(fontSize: 16),
                            ),
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
                        const Text("Aucun soin enregistré."),
                      for (var log in careLogs)
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(log['action'] ?? 'Action inconnue'),
                          subtitle: Text((log['date'] ?? '').toString()),
                        ),
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
