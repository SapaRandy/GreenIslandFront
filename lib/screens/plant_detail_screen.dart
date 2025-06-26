import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/plant.dart';
import '../widgets/sensor_data_widget.dart';

class PlantDetailScreen extends StatefulWidget {
  final Plant plant;
  final String plantId;

  const PlantDetailScreen({Key? key, required this.plant, required this.plantId}) : super(key: key);

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

    final soinsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('mesPlantes')
        .doc(widget.plantId)
        .collection('soins')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      _careHistory = soinsSnapshot.docs.map((d) => d.data()).toList();
      _isLoading = false;
    });
  }

  Future<void> _triggerWatering() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('mesPlantes')
        .doc(widget.plantId)
        .collection('soins')
        .add({
      'type': 'Arrosage',
      'date': now,
    });

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
                child: Image.network(plant.imageUrl, height: 200, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            SensorDataWidget(plantDocId: widget.plantId),
            const SizedBox(height: 16),
            if (plant.latitude != null && plant.longitude != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📍 Localisation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(plant.latitude!, plant.longitude!),
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(plant.id),
                          position: LatLng(plant.latitude!, plant.longitude!),
                        )
                      },
                      zoomControlsEnabled: false,
                      liteModeEnabled: true,
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
            const Text("🕓 Historique des soins", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._careHistory.map((entry) {
              final date = (entry['date'] as Timestamp).toDate();
              final formatted = DateFormat('dd/MM/yyyy HH:mm').format(date);
              return ListTile(
                leading: const Icon(Icons.local_florist),
                title: Text(entry['type'] ?? 'Soins'),
                subtitle: Text(formatted),
              );
            }),
            if (_careHistory.isEmpty) const Text("Aucun soin enregistré."),
          ],
        ),
      ),
    );
  }
}

