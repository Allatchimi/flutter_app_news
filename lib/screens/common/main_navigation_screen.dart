import 'package:app_news/utils/app_colors.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Color backgroundColor;

  const MainNavigationScreen({
    super.key,
    required this.currentIndex,
    required this.onTap, required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      backgroundColor: backgroundColor,
      selectedItemColor: AppColors.whiteColor,
      unselectedItemColor: AppColors.blackColor,
      type: BottomNavigationBarType.fixed,
  
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Recherche'),
        BottomNavigationBarItem(icon: Icon(Icons.ondemand_video),label: 'Vidéos'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
      // Autres propriétés de style...
    );
  }
}
