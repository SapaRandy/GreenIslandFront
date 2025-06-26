import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../models/plant.dart';

class PlantDetailScreen extends StatefulWidget {
  final String plantId;
  final String initialImageUrl;
  final Plant plant;

  const PlantDetailScreen({
    super.key,
    required this.plantId,
    required this.initialImageUrl,
    required this.plant,
  });

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  Plant? _plant;
  List<Map<String, dynamic>> _careHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlantDetails();
  }

  Future<void> _loadPlantDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final List<dynamic> myPlants = userDoc.data()?['mesPlantes'] ?? [];

    final found = myPlants.cast<Map<String, dynamic>>().firstWhere(
          (p) => p['id'] == widget.plantId,
          orElse: () => {},
        );

    if (found.isEmpty) return;

    final historySnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('mesPlantes')
        .doc(widget.plantId)
        .collection('soins')
        .orderBy('date', descending: true)
        .get();

    setState(() {
      _plant = Plant.fromMap(found, widget.plantId);
      _careHistory = historySnap.docs.map((d) => d.data()).toList();
      _isLoading = false;
    });
  }

  Future<void> _triggerWatering() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _plant == null) return;

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

    _loadPlantDetails();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_plant == null) {
      return const Scaffold(body: Center(child: Text("Plante introuvable.")));
    }

    return Scaffold(
      appBar: AppBar(title: Text(_plant!.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_plant!.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _plant!.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 12),
            SensorDataWidget(plantDocId: widget.plantId),
            const SizedBox(height: 16),
            if (_plant!.latitude != null && _plant!.longitude != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("📍 Localisation",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 150,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target:
                            LatLng(_plant!.latitude!, _plant!.longitude!),
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId(_plant!.id),
                          position:
                              LatLng(_plant!.latitude!, _plant!.longitude!),
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
            const Text("🕓 Historique des soins",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._careHistory.map((entry) {
              final date = (entry['date'] as Timestamp).toDate();
              final formatted =
                  DateFormat('dd/MM/yyyy HH:mm').format(date);
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

class SensorDataWidget extends StatelessWidget {
  final String plantDocId;

  const SensorDataWidget({super.key, required this.plantDocId});

  Stream<Map<String, String>> _sensorStream() async* {
    while (true) {
      final tempSnap = await FirebaseFirestore.instance
          .collection('sensor_temperature')
          .where('plantId', isEqualTo: 'plants/$plantDocId')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final humiditySnap = await FirebaseFirestore.instance
          .collection('sensor_humidity')
          .where('plantId', isEqualTo: 'plants/$plantDocId')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      final distSnap = await FirebaseFirestore.instance
          .collection('sensor_distance')
          .where('plantId', isEqualTo: 'plants/$plantDocId')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      yield {
        'Température': tempSnap.docs.isNotEmpty
            ? tempSnap.docs.first['value'].toString()
            : 'N/A',
        'Humidité': humiditySnap.docs.isNotEmpty
            ? humiditySnap.docs.first['value'].toString()
            : 'N/A',
        'Distance': distSnap.docs.isNotEmpty
            ? distSnap.docs.first['value'].toString()
            : 'N/A',
      };

      await Future.delayed(const Duration(seconds: 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, String>>(
      stream: _sensorStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🔍 Données en temps réel",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("🌡️ Température : ${data['Température']}°C"),
            Text("💧 Humidité : ${data['Humidité']}%"),
            Text("📏 Distance : ${data['Distance']} cm"),
          ],
        );
      },
    );
  }
}
