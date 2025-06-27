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

  Future<void> _deletePlant() async {
    try {
      await FirebaseFirestore.instance
          .collection('plants')
          .doc(widget.plantId)
          .delete();

      Fluttertoast.showToast(msg: "Plante supprimée !");
      if (!mounted) return;
      Navigator.pop(context); // Retour à l’écran précédent
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
        .collection('mesPlantes')
        .doc(widget.plantId)
        .collection('soins')
        .add({'type': 'Arrosage', 'date': now});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('🌿 Arrosage déclenché')));

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
            SensorDataWidget(plantDocId: widget.plantId),
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
                          urlTemplate:
                              "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                          userAgentPackageName: 'com.example.yourapp',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 40.0,
                              height: 40.0,
                              point: LatLng(plant.latitude!, plant.longitude!),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                              ),
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
              final date = (entry['date'] as Timestamp).toDate();
              final formatted = DateFormat('dd/MM/yyyy HH:mm').format(date);
              return ListTile(
                leading: const Icon(Icons.local_florist),
                title: Text(entry['type'] ?? 'Soins'),
                subtitle: Text(formatted),
              );
            }),
            if (_careHistory.isEmpty) const Text("Aucun soin enregistré."),
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






// Quand je click sur detailpalntScreen ca s'affiche je vois tous les éléments meme la carte, mais ensuite ca crash et lapp se ferme. J'ai ca dans le terminal apres l'incident:
// E/AndroidRuntime(12575): java.lang.IllegalStateException: API key not found.  Check that <meta-data android:name="com.google.android.geo.API_KEY" android:value="your API key"/> is in the <application> element of AndroidManifest.xml
// E/AndroidRuntime(12575):        at com.google.maps.api.android.lib6.common.g.b(:com.google.android.gms.policy_maps_core_dynamite@252130104@252130101025.762146652.762146652:117)
// E/AndroidRuntime(12575):        at com.google.maps.api.android.lib6.impl.hq.run(:com.google.android.gms.policy_maps_core_dynamite@252130104@252130101025.762146652.762146652:84)
// E/AndroidRuntime(12575):        at java.util.concurrent.ThreadPoolExecutor.processTask(ThreadPoolExecutor.java:1187)
// E/AndroidRuntime(12575):        at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1152)
// E/AndroidRuntime(12575):        at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:641)
// E/AndroidRuntime(12575):        at java.lang.Thread.run(Thread.java:784)
// D/ZrHung.AppEyeUiProbe(12575): stop checker.
// I/Process (12575): Sending signal. PID: 12575 SIG: 9
// Lost connection to device.

// Pourtant j'utilise l'app de flutter normalement ???