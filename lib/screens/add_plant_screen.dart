import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:smartplant_app/screens/home_screen.dart';

class AddPlantScreen extends StatefulWidget {
  const AddPlantScreen({super.key});

  @override
  State<AddPlantScreen> createState() => _AddPlantScreenState();
}

class _AddPlantScreenState extends State<AddPlantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isOutdoor = false;
  File? _pickedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _foundPlantData;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      final ref = FirebaseStorage.instance.ref().child(
        'plants/${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      Fluttertoast.showToast(msg: "Échec upload image : $e");
      return null;
    }
  }

  Future<void> _triggerPlantIdentification() async {
    if (_pickedImage == null) {
      Fluttertoast.showToast(msg: "Aucune image sélectionnée");
      return;
    }
    setState(() => _isLoading = true);
    try {
      final uri = Uri.parse('http://greenislandback.onrender.com/plantid/identify/');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(
          await http.MultipartFile.fromPath('image', _pickedImage!.path),
        );
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['plant_name'];
        if (name != null) {
          _nameController.text = name;
          Fluttertoast.showToast(msg: "Plante reconnue : $name");
          await _searchPlantByName(name);
        } else {
          Fluttertoast.showToast(msg: "Plante non reconnue");
        }
      } else {
        Fluttertoast.showToast(msg: "Erreur serveur : ${response.statusCode}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur identification : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchPlantByName(String name) async {
    if (name.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final queryLower = name.trim().toLowerCase();

      // Étape 1 : récupérer toutes les plantes de l’utilisateur
      final allDocs = await FirebaseFirestore.instance
          .collection('plants')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('plants_data')
          .get();

      // Recherche floue locale
      final matchingDocs = allDocs.docs.where((doc) {
        final plantName = (doc['name'] ?? '').toString().toLowerCase();
        return plantName.contains(queryLower);
      }).toList();

      if (matchingDocs.isEmpty) {
        Fluttertoast.showToast(msg: "Aucune plante trouvée dans vos données.");
        setState(() => _foundPlantData = null);
        return;
      }

      final plantData = matchingDocs.first
          .data(); // Tu peux afficher plus tard une liste si tu veux

      // Étape 2 : enrichir depuis 'plants_data' si possible
      // Étape 2 : enrichir depuis 'plants_data'
      final enrichSnapshot = await FirebaseFirestore.instance
          .collection('plants_data')
          .get();

      QueryDocumentSnapshot<Map<String, dynamic>>? enrichMatch;
      try {
        enrichMatch = enrichSnapshot.docs.firstWhere(
          (doc) =>
              (doc['name'] ?? '').toString().toLowerCase().contains(queryLower),
        );
      } catch (e) {
        enrichMatch = null;
      }

      if (enrichMatch != null) {
        final enriched = enrichMatch.data();
        plantData['details'] = enriched['details'] ?? {};
      }

      setState(() => _foundPlantData = plantData);
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur lors de la recherche : $e");
      setState(() => _foundPlantData = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _foundPlantData == null) return;

    setState(() => _isLoading = true);
    String? imageUrl;
    if (_pickedImage != null) {
      imageUrl = await _uploadImageToStorage(_pickedImage!);
      if (imageUrl == null) {
        setState(() => _isLoading = false);
        return;
      }
    }

    Position? position;
    if (_isOutdoor) {
      try {
        var perm = await Geolocator.checkPermission();
        if (perm == LocationPermission.denied ||
            perm == LocationPermission.deniedForever) {
          perm = await Geolocator.requestPermission();
        }
        position = await Geolocator.getCurrentPosition();
      } catch (e) {
        Fluttertoast.showToast(msg: "Erreur géoloc : $e");
      }
    }

    try {
      final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      final plantData = {
        ..._foundPlantData!,
        'name': _nameController.text.trim(),
        'imageUrl': imageUrl ?? _foundPlantData!['imageUrl'] ?? '',
        'addedAt': FieldValue.serverTimestamp(),
        'isOutdoor': _isOutdoor,
        if (position != null) ...{
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      };

      await userDoc.update({
        'mesPlantes': FieldValue.arrayUnion([plantData]),
      });

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Erreur Firestore : $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une plante')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_pickedImage != null)
                Image.file(_pickedImage!, height: 200, fit: BoxFit.cover),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Choisir une image"),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _triggerPlantIdentification,
                icon: const Icon(Icons.search),
                label: const Text("Identifier via IA"),
              ),
              ElevatedButton.icon(
                onPressed: _pickedImage == null
                    ? null
                    : _triggerPlantIdentification,
                icon: const Icon(Icons.cancel),
                label: const Text("Supprimer l'image"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nom de la plante",
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _searchPlantByName(_nameController.text),
                icon: const Icon(Icons.search),
                label: const Text("Rechercher par nom"),
              ),
              const SizedBox(height: 12),
              if (_foundPlantData != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Informations trouvées :",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Nom : ${_foundPlantData!['name'] ?? '-'}"),
                    Text("Détails : ${_foundPlantData!['details'] ?? '-'}"),
                    if (_foundPlantData!['imageUrl'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Image.network(
                          _foundPlantData!['imageUrl'],
                          height: 120,
                        ),
                      ),
                  ],
                ),
              CheckboxListTile(
                title: const Text("Plante en extérieur"),
                value: _isOutdoor,
                onChanged: (v) => setState(() => _isOutdoor = v ?? false),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save),
                      label: const Text("Enregistrer"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
