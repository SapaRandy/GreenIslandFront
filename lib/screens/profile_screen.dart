import 'package:flutter/material.dart';
import 'logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil utilisateur"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=47',
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text("Jean Dupont", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
          const Center(
            child: Text("jean.dupont@email.com", style: TextStyle(color: Colors.grey)),
          ),
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.water_drop),
            title: const Text("Arrosage automatique"),
            trailing: Switch(value: true, onChanged: (v) {}),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text("Aide & FAQ"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          // ✅ Remplacement par le composant réutilisable :
          const LogoutButton(),
        ],
      ),
    );
  }
}
