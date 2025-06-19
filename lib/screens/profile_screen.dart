import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'logout_button.dart';
import 'devices_screen.dart';
import 'sensor_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Variable globale pour l'état de l'arrosage automatique
bool autoWateringEnabled = false; // au-dessus du build()

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _photoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseStorage.instance
        .ref()
        .child('profile_pictures')
        .child('${user.uid}.jpg');

    await ref.putFile(File(file.path));
    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'photoUrl': imageUrl,
    });

    setState(() {
      userData!['photoUrl'] = imageUrl;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Photo de profil mise à jour.")),
    );
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();

    if (data != null) {
      setState(() {
        userData = data;
        _nameController.text = data['fullName'] ?? '';
        _photoUrlController.text = data['photoUrl'] ?? '';
        isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'fullName': _nameController.text.trim(),
      'photoUrl': _photoUrlController.text.trim(),
    });

    setState(() {
      userData!['fullName'] = _nameController.text.trim();
      userData!['photoUrl'] = _photoUrlController.text.trim();
    });

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil mis à jour avec succès')),
    );
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le profil'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom complet'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez saisir un nom'
                    : null,
              ),
              TextFormField(
                controller: _photoUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL photo de profil',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _updateUserProfile();
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarUrl =
        userData?['photoUrl'] ?? 'https://i.pravatar.cc/150?img=47';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F2),
      appBar: AppBar(
        title: const Text("Mon Profil"),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier le profil',
            onPressed: _showEditDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(avatarUrl),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 15,
                        child: Icon(Icons.edit, size: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: Text(
                    userData?['fullName'] ?? 'Nom inconnu',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    userData?['email'] ?? 'Email inconnu',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const Divider(height: 40),

                // ✅ Nouvelle carte : Appareils connectés
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.devices, color: Colors.teal),
                    title: const Text("Appareils connectés"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DevicesScreen(),
                        ),
                      );
                    },
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.notifications_active,
                      color: Colors.green,
                    ),
                    title: const Text("Notifications"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SensorsScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  child: SwitchListTile(
                    value: autoWateringEnabled,
                    onChanged: (value) {
                      setState(() {
                        autoWateringEnabled = value;
                      });
                    },
                    title: const Text("Arrosage automatique"),
                    secondary: const Icon(Icons.water_drop, color: Colors.blue),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.help_outline,
                      color: Colors.orange,
                    ),
                    title: const Text("Aide & FAQ"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {},
                  ),
                ),
                const SizedBox(height: 20),
                const LogoutButton(),
              ],
            ),
    );
  }
}
