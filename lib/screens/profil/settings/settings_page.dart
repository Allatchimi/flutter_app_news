import 'package:app_news/screens/profil/settings/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'widgets/settings_switch_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres")),
      body: ListView(
        children: [
          SettingsSection(
            title: "Affichage",
            children: [
              SettingsSwitchTile(
                title: "Mode sombre",
                value: _darkMode,
                onChanged: _updateDarkMode,
              ),
              SettingsSwitchTile(
                title: "Afficher images",
                value: true,
                onChanged: _updateShowImages,
              ),
            ],
          ),
          SettingsSection(
            title: "Notifications",
            children: [
              SettingsSwitchTile(
                title: "Notifications push",
                value: _notifications,
                onChanged: _updateNotifications,
              ),
            ],
          ),
        ],
      ),
    );
  }



  void _updateDarkMode(bool value) {
    setState(() {
      _darkMode = value;
      // Logique pour appliquer le mode sombre
    });
  }

  void _updateShowImages(bool value) {
    setState(() {
      // Logique pour afficher/masquer les images
    });
  }
  _showImages(bool value) {
    setState(() {
      // Logique pour afficher/masquer les images
    });
  }

  void _updateNotifications(bool value) {
    setState(() {
      _notifications = value;
      // Logique pour activer/désactiver les notifications
    });
  }
}

class _showImages {
}