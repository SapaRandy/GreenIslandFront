import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Map<String, dynamic>> availableDevices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevicesFromBackend();
  }

  Future<void> _loadDevicesFromBackend() async {
    setState(() => isLoading = true);
    try {
      final url = Uri.parse("https://greenislandback.onrender.com/arduino/connect");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final devices = jsonList.map<Map<String, dynamic>>((item) {
          return {
            'id': item['id'] ?? '',
            'name': item['name'] ?? 'Sans nom',
            'location': item['location'] ?? '',
          };
        }).toList();

        setState(() {
          availableDevices = devices;
          isLoading = false;
        });
      } else {
        throw Exception("Erreur ${response.statusCode} : ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement : $e")),
      );
    }
  }

  Future<void> _connectToDevice(String deviceId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse("https://greenislandback.onrender.com/arduino/connect");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userid": user.uid,
          "uniqueID": deviceId,
        }),
      );

      if (response.statusCode == 200) {
        // Met à jour le statut dans Firebase si besoin
        await FirebaseFirestore.instance.collection('devices').doc(deviceId).update({
          'status': 'active',
          'userId': user.uid,
        });

        setState(() {
          availableDevices.removeWhere((d) => d['id'] == deviceId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appareil connecté avec succès.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur backend : ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur connexion : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Appareils disponibles"),
        backgroundColor: Colors.green.shade700,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDevicesFromBackend,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableDevices.isEmpty
              ? const Center(child: Text("Aucun appareil libre disponible."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: availableDevices.length,
                  itemBuilder: (context, index) {
                    final device = availableDevices[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.devices, color: Colors.green),
                        title: Text(device['name']),
                        subtitle: Text("Lieu : ${device['location']}"),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _connectToDevice(device['id']),
                          icon: const Icon(Icons.link),
                          label: const Text("Connecter"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
