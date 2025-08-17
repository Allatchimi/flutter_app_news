import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkTheme = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paramètres"),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: Text("Thème sombre"),
            value: isDarkTheme,
            onChanged: (value) {
              setState(() => isDarkTheme = value);
            },
            secondary: Icon(Icons.brightness_6),
          ),
          SwitchListTile(
            title: Text("Notifications"),
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
            secondary: Icon(Icons.notifications),
          ),
          ListTile(
            leading: Icon(Icons.language),
            title: Text("Langue"),
            subtitle: Text("Français"),
            onTap: () {
              // Afficher un sélecteur de langue
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text("Changer le mot de passe"),
            onTap: () {
              // Rediriger vers une page de changement de mot de passe
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Se déconnecter", style: TextStyle(color: Colors.red)),
            onTap: () {
              // Déconnexion
            },
          ),
        ],
      ),
    );
  }
}
