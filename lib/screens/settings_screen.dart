import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _renameDevice(String docId, String currentName) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentName);
        return AlertDialog(
          title: const Text("Renommer le capteur"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nouveau nom"),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("Renommer"),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      await FirebaseFirestore.instance.collection('devices').doc(docId).update({'name': newName});
      Fluttertoast.showToast(msg: "Nom mis à jour");
    }
  }

  Future<void> _unlinkDevice(String docId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('devices')
        .doc(docId)
        .get();

    final plantId = snapshot.data()?['plantId'];

    if (plantId == null) {
      print("Aucune plante liée à ce capteur.");
      return;
    }

    final url = Uri.parse(
      "https://greenislandback.onrender.com/plantid/connect/$docId/$plantId/",
    );

    final response = await http.delete(url); // Appel DELETE

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Dissociation réussie !");
      // Tu peux afficher un toast ou rafraîchir l'UI si besoin
    } else {
      Fluttertoast.showToast(msg: "Erreur ${response.statusCode}");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur connexion : $e")),
      );
  }
}

  Future<void> _deleteDevice(String docId) async {
    final url = Uri.parse("https://greenislandback.onrender.com/arduino/connect/$docId/");

    try {
      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Device supprimé");
      } else {
        Fluttertoast.showToast(msg: "Erreur ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur connexion : $e")),
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
          "userId": user.uid,
          "uniqueID": deviceId,
        }),
      );

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Appareil connecté avec succès");
      } else {
        Fluttertoast.showToast(msg: "Erreur backend : ${response.body}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur connexion : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('devices')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Erreur de chargement"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) return const Center(child: Text("Aucun device connecté"));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              return ListTile(
                leading: const Icon(Icons.sensors),
                title: Text(data['name'] ?? 'Sans nom'),
                subtitle: Text(data['location'] ?? 'Localisation inconnue'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) async {
                    switch (value) {
                      case 'connect':
                        await _connectToDevice(doc.id);
                        break;
                      case 'rename':
                        await _renameDevice(doc.id, data['name'] ?? '');
                        break;
                      case 'unlink':
                        await _unlinkDevice(doc.id);
                        break;
                      case 'delete':
                        await _deleteDevice(doc.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'connect', child: Text("Connecter")),
                    const PopupMenuItem(value: 'rename', child: Text("Renommer")),
                    const PopupMenuItem(value: 'unlink', child: Text("Dissocier")),
                    const PopupMenuItem(value: 'delete', child: Text("Supprimer")),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
