import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../models/plant.dart';
import '../widgets/sensor_data_widget.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  final String plantId;

  const PlantDetailScreen({
    Key? key,
    required this.plant,
    required this.plantId,
  }) : super(key: key);

  @override
  _PlantDetailScreenState createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  List<Map<String, dynamic>> _careHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCareHistory();
  }

  Future<void> _loadCareHistory() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final soinsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('plants')
          .doc(widget.plantId)
          .collection('soins')
          .orderBy('date', descending: true)
          .get();

      setState(() {
        _careHistory = soinsSnapshot.docs.map((d) => d.data()).toList();
        _isLoading = false;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur chargement soins : $e");
      setState(() {
        _careHistory = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePlant() async {
    try {
      await FirebaseFirestore.instance
          .collection('plants')
          .doc(widget.plantId)
          .delete();

      Fluttertoast.showToast(msg: "Plante supprimée !");
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur suppression : $e");
    }
  }

  Future<void> _triggerWatering() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('plants')
        .doc(widget.plantId)
        .collection('soins')
        .add({'type': 'Arrosage', 'date': now});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🌿 Arrosage déclenché')),
    );

    _loadCareHistory();
  }

  @override
  Widget build(BuildContext context) {
    final plant = widget.plant;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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

            // ✅ Données capteurs en live
            SensorDataWidget(plantId: widget.plantId),
            const SizedBox(height: 16),

            Text(
              plant.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            // 🌍 Carte de géolocalisation
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

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _triggerWatering,
              icon: const Icon(Icons.water_drop),
              label: const Text("Arroser maintenant"),
            ),

            const SizedBox(height: 24),
            const Text(
              "🕓 Historique des soins",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            ..._careHistory.map((entry) {
              try {
                final date = (entry['date'] as Timestamp).toDate();
                final formatted = DateFormat('dd/MM/yyyy HH:mm').format(date);
                return ListTile(
                  leading: const Icon(Icons.local_florist),
                  title: Text(entry['type'] ?? 'Soins'),
                  subtitle: Text(formatted),
                );
              } catch (_) {
                return const ListTile(
                  leading: Icon(Icons.error, color: Colors.red),
                  title: Text("Entrée invalide"),
                );
              }
            }),

            if (_careHistory.isEmpty)
              const Text("Aucun soin enregistré."),

            const SizedBox(height: 12),
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
