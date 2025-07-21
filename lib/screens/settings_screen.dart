import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    await FirebaseFirestore.instance.collection('devices').doc(docId).update({'userId': null});
    Fluttertoast.showToast(msg: "Device dissocié");
  }

  Future<void> _deleteDevice(String docId) async {
    await FirebaseFirestore.instance.collection('devices').doc(docId).delete();
    Fluttertoast.showToast(msg: "Device supprimé");
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

          if (docs.isEmpty) return const Center(child: Text("Aucun capteur connecté"));

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
