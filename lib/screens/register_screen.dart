import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Créer un compte")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: passwordCtrl, decoration: InputDecoration(labelText: "Mot de passe"), obscureText: true),
            TextField(controller: confirmCtrl, decoration: InputDecoration(labelText: "Confirmer le mot de passe"), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implémenter l'enregistrement
              },
              child: Text("S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
