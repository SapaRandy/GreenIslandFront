import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/plant.dart';
import '../widgets/sensor_data_widget.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  final String plantId;
  final String deviceId;


  const PlantDetailScreen({
    Key? key,
    required this.plant,
    required this.plantId,
    this.deviceId = '',
  }) : super(key: key);

  @override
  _PlantDetailScreenState createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {


  // ⬇️ AJOUT
  Future<void> _showDeviceSelector() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('devices')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .get();

    final devices = snapshot.docs;

    if (devices.isEmpty) {
      Fluttertoast.showToast(msg: "Aucun device disponible.");
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final data = devices[index].data();
          final id = devices[index].id;
          return ListTile(
            leading: const Icon(Icons.sensors),
            title: Text(data['name'] ?? 'Device'),
            subtitle: Text("📍 ${data['location'] ?? ''}"),
            onTap: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('plants')
                  .doc(widget.plantId)
                  .update({'deviceId': id}); // ou 'deviceId' si renommé

              Fluttertoast.showToast(msg: "Device associé !");
              setState(() {});
            },
          );
        },
      ),
    );
  }
  // ⬆️ FIN AJOUT

  Future<void> _triggerWatering() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('plants')
          .doc(widget.plantId)
          .update({'auto': true});

      Fluttertoast.showToast(msg: "🌿 Arrosage automatique activé !");
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur : $e");
    }
  }

  Future<void> _deletePlant() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('plants')
          .doc(widget.plantId)
          .delete();

      Fluttertoast.showToast(msg: "Plante supprimée !");
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur suppression : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    return Scaffold(
      appBar: AppBar(title: Text(plant.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plant.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  plant.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),

            SensorDataWidget(plantId: widget.plantId),
            const SizedBox(height: 16),

            Text(
              plant.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            if (plant.latitude != null && plant.longitude != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "📍 Localisation",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: FlutterMap(
                      options: MapOptions(
                        center: LatLng(plant.latitude!, plant.longitude!),
                        zoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40.0,
                              height: 40.0,
                              point: LatLng(plant.latitude!, plant.longitude!),
                              child: const Icon(Icons.location_pin, color: Colors.red),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            if ((plant.deviceId ?? '').isEmpty || plant.deviceId == 'none')
            ElevatedButton.icon(
              onPressed: _showDeviceSelector,
              icon: const Icon(Icons.sensors),
              label: const Text("Associer un capteur"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _triggerWatering,
              icon: const Icon(Icons.water_drop),
              label: const Text("Activer l’arrosage automatique"),
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Confirmation"),
                    content: const Text("Supprimer cette plante ?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deletePlant();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text("Supprimer"),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete),
              label: const Text("Supprimer la plante"),
            ),
          ],
        ),
      ),
    );
  }
}
