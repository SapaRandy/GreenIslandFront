import 'package:flutter/material.dart';

class AddPlantScreen extends StatelessWidget {
  final nameCtrl = TextEditingController();

  AddPlantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter une plante")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: "Nom de la plante")),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: ajouter reconnaissance IA ici
              },
              icon: Icon(Icons.camera_alt),
              label: Text("Identifier par photo"),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: enregistrer plante
              },
              child: Text("Ajouter"),
            ),
          ],
        ),
      ),
    );
  }
}
