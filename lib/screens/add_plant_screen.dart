import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

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

  File? _pickedImage;

  Future<void> _pickImage() async {
    final pf = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pf != null) {
      final file = File(pf.path);
      setState(() => _pickedImage = file);
      await _identifyPlantFromImage(file);
    }
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final fileName =
          'plants/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      final uploadTask = await ref.putFile(imageFile);
      final url = await uploadTask.ref.getDownloadURL();

      return url;
    } catch (e) {
      debugPrint('Erreur upload image: $e');
      return null;
    }
  }

  Future<void> _identifyPlantFromImage(File image) async {
    try {
      final bytes = await image.readAsBytes();
      final response = await http.post(
        Uri.parse('http://172.30.192.1/plantid/identify/'),
        headers: {'Content-Type': 'application/octet-stream'},
        body: bytes,
      );
      if (response.statusCode == 200) {
        final name = jsonDecode(response.body)['plantName'] as String;
        _nameController.text = name;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Plante identifiée : $name')));
      } else {
        throw Exception('Status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur identification IA externe : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Échec de reconnaissance")));
    }
  }

  Future<void> _submitPlant() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Non connecté.")));
      return;
    }

    String? finalImageUrl;

    if (_pickedImage != null) {
      final uploadedUrl = await _uploadImageToStorage(_pickedImage!);
      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'upload de l'image.")),
        );
        return;
      }
    }

    Position? position;
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint("Erreur de géolocalisation : $e");
    }

    try {
      await FirebaseFirestore.instance.collection('plants').add({
        'name': _nameController.text.trim(),
        'room': _roomController.text.trim(),
        'humidity': _humidityController.text.trim(),
        'temp': _tempController.text.trim(),
        'imageUrl': finalImageUrl ?? '', // ← ici image obligatoire si chargée
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        if (position != null) ...{
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Plante ajoutée !")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajouter une plante"),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_pickedImage != null)
                Image.file(_pickedImage!, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_camera),
                label: const Text("Identifier via photo"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const Divider(height: 40),
              const Text(
                "Infos de la plante",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? "Nom requis" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _roomController,
                decoration: const InputDecoration(
                  labelText: 'Pièce',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _humidityController,
                decoration: const InputDecoration(
                  labelText: 'Humidité (%)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tempController,
                decoration: const InputDecoration(
                  labelText: 'Température (°C)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // TextFormField(
              //   controller: _imageUrlController,
              //   decoration: const InputDecoration(
              //     labelText: 'URL de l\'image (optionnel)',
              //     border: OutlineInputBorder(),
              //   ),
              //   validator: (v) => v!.isEmpty ? "URL optionnelle" : null,
              // ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitPlant,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
