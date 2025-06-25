import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class PlantDetailScreen extends StatefulWidget {
  final Map<String, dynamic> plantData;
  const PlantDetailScreen({super.key, required this.plantData});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  late Map<String, dynamic> _plant;
  bool _isLoading = false;
  List<Map<String, dynamic>> _careLogs = [];

  @override
  void initState() {
    super.initState();
    _plant = widget.plantData;
    _loadCareLogs();
  }

  Future<void> _loadCareLogs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _plant['name'] == null) return;
    final logsSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('careLogs')
        .where('plantName', isEqualTo: _plant['name'])
        .orderBy('timestamp', descending: true)
        .get();

    setState(() {
      _careLogs = logsSnapshot.docs.map((d) => d.data()).toList();
    });
  }

  Future<void> _triggerWatering() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _plant['name'] == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('careLogs')
          .add({
        'plantName': _plant['name'],
        'action': 'Arrosage',
        'timestamp': Timestamp.now(),
      });
      Fluttertoast.showToast(msg: "Arrosage enregistré !");
      _loadCareLogs();
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur arrosage : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final temperature = _plant['temp'] ?? '--';
    final humidity = _plant['humidity'] ?? '--';
    final dist = _plant['dist'] ?? '--';
    final lat = _plant['latitude'];
    final lng = _plant['longitude'];

    return Scaffold(
      appBar: AppBar(title: Text(_plant['name'] ?? 'Plante')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_plant['imageUrl'] != null)
              Image.network(_plant['imageUrl'], height: 180, fit: BoxFit.cover),
            const SizedBox(height: 12),
            Text('Détails : ${_plant['details'] ?? '-'}'),
            Text('Température : $temperature °C'),
            Text('Humidité : $humidity %'),
            Text('Niveau d’eau : $dist'),
            if (lat != null && lng != null)
              SizedBox(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 15,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId('plant_location'),
                      position: LatLng(lat, lng),
                    ),
                  },
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _triggerWatering,
              icon: const Icon(Icons.water_drop),
              label: const Text("Arroser la plante"),
            ),
            const SizedBox(height: 16),
            const Text("Historique de soins", style: TextStyle(fontWeight: FontWeight.bold)),
            if (_careLogs.isEmpty)
              const Text("Aucun soin enregistré."),
            for (final log in _careLogs)
              ListTile(
                leading: const Icon(Icons.event_note),
                title: Text(log['action'] ?? '-'),
                subtitle: Text(dateFormat.format((log['timestamp'] as Timestamp).toDate())),
              ),
          ],
        ),
      ),
    );
  }
}
