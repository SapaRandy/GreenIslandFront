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
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pf = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pf != null) {
      final file = File(pf.path);
      if (!file.existsSync()) {
        Fluttertoast.showToast(
          msg: "🪴 ${_nameController.text.trim()} ajoutée avec succès",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green.shade700,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Image non trouvée.")));

        return;
      }
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
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Erreur upload image: $e');
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
        final name = data['plantName'] as String;
        _nameController.text = name;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Plante identifiée : $name')));
      } else {
        throw Exception('Erreur API ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Erreur API IA : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Échec de la reconnaissance de plante")),
      );
    }
  }

  Future<void> _submitPlant() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Utilisateur non connecté.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String? finalImageUrl;
    if (_pickedImage != null) {
      final uploadedUrl = await _uploadImageToStorage(_pickedImage!);
      if (uploadedUrl == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'upload de l'image.")),
        );
        return;
      }
      finalImageUrl = uploadedUrl;
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
      debugPrint("Erreur géolocalisation : $e");
    }

    try {
      await FirebaseFirestore.instance.collection('plants').add({
        'name': _nameController.text.trim(),
        'room': _roomController.text.trim(),
        'humidity': _humidityController.text.trim(),
        'temp': _tempController.text.trim(),
        'imageUrl': finalImageUrl ?? '',
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
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

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Plante ajoutée avec succès !")),
      );
    } catch (e) {
      debugPrint('Erreur ajout plante : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : ${e.toString()}")));
    } finally {
      setState(() => _isLoading = false);
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
                  labelText: 'Niveau d\'eau',
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
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tempController,
                decoration: const InputDecoration(
                  labelText: 'Température (°C)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submitPlant,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
