import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PlantDetailScreen extends StatelessWidget {
  final String plantId;
  final String plantName;
  final String room;
  final String imageUrl;
  final String humidity;
  final String temp;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    required this.plantName,
    required this.room,
    required this.imageUrl,
    required this.humidity,
    required this.temp,
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

  void _editPlant(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: plantName);
    final roomController = TextEditingController(text: room);
    final humidityController = TextEditingController(text: humidity);
    final tempController = TextEditingController(text: temp);
    final imageUrlController = TextEditingController(text: imageUrl);

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
            key: _formKey,
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
                    decoration: const InputDecoration(labelText: 'Pièce'),
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
                      if (!_formKey.currentState!.validate()) return;
                      try {
                        await FirebaseFirestore.instance
                            .collection('plants')
                            .doc(plantId)
                            .update({
                              'name': nameController.text.trim(),
                              'room': roomController.text.trim(),
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
        title: Text(plantName),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editPlant(context),
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
          final latitude = data['latitude'];
          final longitude = data['longitude'];
          final careLogs = (data['careLogs'] ?? []) as List;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.network(imageUrl, height: 250, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plantName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Pièce : $room",
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
                        Text(
                          "📍 Localisation : $latitude, $longitude",
                          style: const TextStyle(fontSize: 16),
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
