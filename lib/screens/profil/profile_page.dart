
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  
  final String userName = "Amine Kellan";
  final String email = "amine@example.com";
  final String profileImageUrl = "https://via.placeholder.com/150"; // Remplace par une vraie URL


  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(profileImageUrl),
            ),
            SizedBox(height: 16),
            Text(userName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(email, style: TextStyle(color: Colors.grey[600])),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Redirige vers l'édition du profil
              },
              icon: Icon(Icons.edit),
              label: Text("Modifier le profil"),
            ),
            Spacer(),
            Text("Membre depuis : août 2025", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
