import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _roomController = TextEditingController();
  final _humidityController = TextEditingController();
  final _tempController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String get imagePreviewUrl => _imageUrlController.text.trim();

  void _submitPlant() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Utilisateur non connecté.")),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('plants').add({
          'name': _nameController.text.trim(),
          'room': _roomController.text.trim(),
          'humidity': _humidityController.text.trim(),
          'temp': _tempController.text.trim(),
          'imageUrl': imagePreviewUrl,
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🌱 Plante ajoutée avec succès !")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.toString()}")),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    _humidityController.dispose();
    _tempController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une plante 🌿"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("🪴 Informations générales", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de la plante',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_florist),
                ),
                validator: (value) => value!.isEmpty ? "Nom requis" : null,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Pièce (optionnel)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.chair_alt),
                ),
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _humidityController,
                decoration: const InputDecoration(
                  labelText: 'Humidité (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _tempController,
                decoration: const InputDecoration(
                  labelText: 'Température (°C)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.thermostat),
                ),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l’image',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                ),
                onChanged: (_) => setState(() {}),
              ),

              if (imagePreviewUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imagePreviewUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Text("Image non valide"),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitPlant,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer la plante"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// This code defines a screen for adding a new plant to the user's collection.
// It includes a form for entering plant details and saving them to Firestore.