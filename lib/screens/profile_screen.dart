import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const ProfileScreen({super.key, required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profil")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.account_circle, size: 100),
            const SizedBox(height: 20),
            Text(userName, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(userEmail),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Déconnexion
              },
              icon: Icon(Icons.logout),
              label: Text("Se déconnecter"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
