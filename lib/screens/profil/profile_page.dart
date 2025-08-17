import 'package:app_news/screens/profil/settings/settings_page.dart';
import 'package:app_news/screens/profil/widgets/profile_avatar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profil')),
      body: Column(
        children: [
          //UserHeader(), // Photo + infos basiques
          const ProfileAvatar(imageUrl: 'https://i.pravatar.cc/150?img=3'),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          const Text(
            "Amine Kellan",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "amine.kellan@example.com",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Modifier le profil"),
            onTap: () {
              // Ajouter la logique pour éditer le profil
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Changer mot de passe"),
            onTap: () {
              // Ajouter la logique pour changer le mot de passe
            },
          ),
          ListTile(
            title: Text('Mon Profil'),
            leading: Icon(Icons.person),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            ),
          ),
          SizedBox(height: 10),
          ListTile(
            title: Text('Paramètres'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            ),
          ),

          // Autres options de profil...
        ],
      ),
    );
  }
}
