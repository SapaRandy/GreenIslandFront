// FICHIER: add_plant_screen.dart

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'dashboard_screen.dart';

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

  File? _pickedImage;
  bool _isOutdoor = false;
  bool _isLoading = false;

  Future<void> _pickImageFromGallery() async {
    final pf = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pf == null) return;

    final file = File(pf.path);
    if (!file.existsSync()) {
      Fluttertoast.showToast(msg: "Image introuvable");
      return;
    }

    setState(() => _pickedImage = file);
    await _identifyPlantFromImage(file);
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final ref = FirebaseStorage.instance
          .ref()
          .child('plants/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Upload failed: $e');
      return null;
    }
  }

  Future<void> _identifyPlantFromImage(File image) async {
    try {
      final uri = Uri.parse('http://172.30.192.1:8000/plantid/identify/');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', image.path));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _nameController.text = data['plantName'];
        Fluttertoast.showToast(msg: 'Plante reconnue : ${data['plantName']}');
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erreur IA : $e');
    }
  }

  Future<void> _submitPlant() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isLoading = true);
    String? imageUrl;

    if (_pickedImage != null) {
      imageUrl = await _uploadImageToStorage(_pickedImage!);
      if (imageUrl == null) {
        setState(() => _isLoading = false);
        Fluttertoast.showToast(msg: "Échec de l'upload image.");
        return;
      }
    }

    Position? position;
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }
      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      debugPrint("Géoloc désactivée : $e");
    }

    try {
      await FirebaseFirestore.instance.collection('plants').add({
        'name': _nameController.text.trim(),
        'dist': _roomController.text.trim(),
        'humidity': _humidityController.text.trim(),
        'temp': _tempController.text.trim(),
        'imageUrl': imageUrl ?? '',
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isOutdoor': _isOutdoor,
        if (position != null) ...{
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur sauvegarde : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_pickedImage != null)
          Stack(
            children: [
              Image.file(_pickedImage!, height: 200, fit: BoxFit.cover),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _pickedImage = null),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.close, color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _pickImageFromGallery,
          icon: const Icon(Icons.camera_alt),
          label: const Text("Scanner ma plante"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        const SizedBox(height: 12),
        const Text("Ou entrez manuellement les informations :",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFormSection() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text("La plante est en extérieur"),
          value: _isOutdoor,
          onChanged: (v) => setState(() => _isOutdoor = v ?? false),
        ),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nom'),
          validator: (v) => v!.isEmpty ? "Nom requis" : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _roomController,
          decoration: const InputDecoration(labelText: 'Niveau d’eau'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _humidityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Humidité (%)'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _tempController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Température (°C)'),
        ),
      ],
    );
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
              _buildImagePickerSection(),
              const Divider(),
              _buildFormSection(),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                      onPressed: _submitPlant,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
