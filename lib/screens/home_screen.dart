import 'package:app_news/screens/favorites_page.dart';
import 'package:app_news/screens/home_content.dart';
import 'package:app_news/screens/main_navigation_screen.dart';
import 'package:app_news/screens/profil_screen.dart';
import 'package:app_news/screens/profile_page.dart';
import 'package:app_news/screens/search_page.dart';
import 'package:app_news/screens/video_feed_page.dart';

import 'package:app_news/utils/app_colors.dart';

import 'package:app_news/widgets/generic_app_bar.dart';

import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Liste des écrans correspondant à chaque onglet de navigation
  final List<Widget> _screens = [
    const HomeContent(),    // Onglet Accueil
    const SearchPage(),     // Onglet Recherche
    const VideoFeedPage(),  // Onglet Vidéos
    const FavoritesPage(),  // Onglet Enregistrés
    const ProfilePage(),  // Onglet Profil
  ];

  // Titres pour chaque onglet (optionnel)
  final List<String> _titles = [
    'Accueil',
    'Recherche',
    'Vidéos',
    'Favorites',
    'Profil'
  ];
  //Text(_titles[_currentIndex]
  @override
  Widget build(BuildContext context) {
    String text = _titles[_currentIndex];
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
  appBar: GenericAppBar(
    title: text,
    backgroundColor: AppColors.primaryColor,
    automaticallyImplyLeading: false,
    actions: [
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () => Navigator.push(context, 
            MaterialPageRoute(builder: (_) => const SearchPage()
          )
      ) 
    ),
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: () => _showNotifications(),
      ),
      IconButton(
        icon: const Icon(Icons.account_circle),
        onPressed: () => Navigator.push(context, 
            MaterialPageRoute(builder: (_) => const ProfileScreen())),
      ),
    ],
  ),
      body: _screens[_currentIndex],
      bottomNavigationBar: MainNavigationScreen(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.primaryColor,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        }, 
      ),
    );
  }
  
  void _showNotifications() {}
}