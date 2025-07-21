// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Map<String, dynamic>> availableDevices = [];
  bool isLoading = true;
  String? connectedDeviceId;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('devices')
          .where('status', isEqualTo: 'free')
          .get();

      final devices = querySnapshot.docs.map((doc) {
        // ignore: avoid_print
        print("Chargement des devices...");
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Sans nom',
          'location': data['location'] ?? '',
          'ip': data['IP'] ?? '',
        };
      }).toList();
      print("Nombre de résultats : ${querySnapshot.docs.length}");
      for (var doc in querySnapshot.docs) {
        print("Device trouvé : ${doc.id} -> ${doc.data()}");
      }

      setState(() {
        availableDevices = devices;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
    
  }

  Future<void> _connectToDevice(String deviceId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final url = Uri.parse("http://greenislandback.onrender.com/arduino/connect");
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
        setState(() {
          connectedDeviceId = deviceId;
          availableDevices.removeWhere((d) => d['id'] == deviceId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appareil connecté avec succès')),
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
    final themeColor = Colors.green.shade700;

    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        backgroundColor: themeColor,
        title: const Text("Appareils disponibles"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDevices,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : availableDevices.isEmpty
              ? const Center(child: Text("Aucun appareil libre trouvé."))
              : ListView.builder(
                  itemCount: availableDevices.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final device = availableDevices[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: const Icon(Icons.sensors,
                            size: 36, color: Colors.green),
                        title: Text(
                          device['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          "Lieu : ${device['location']}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () => _connectToDevice(device['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.link),
                          label: const Text("Connecter"),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
