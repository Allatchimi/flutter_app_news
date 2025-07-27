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

  final List<Widget> _screens = [
    const HomeContent(),
    const SearchPage(),
    const VideoFeedPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  final List<String> _titles = [
    'Accueil',
    'Recherche',
    'Vidéos',
    'Favorites',
    'Profil'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      // N'affiche pas l'AppBar quand on est sur la page de recherche (index 1)
      appBar: _currentIndex == 1 ? null : _buildAppBar(),
      body: _screens[_currentIndex],
      bottomNavigationBar: MainNavigationScreen(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.primaryColor,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return GenericAppBar(
      title: _titles[_currentIndex],
      backgroundColor: AppColors.primaryColor,
      automaticallyImplyLeading: false,
      actions: [
        if (_currentIndex != 1)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _currentIndex = 1),
          ),
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: _showNotifications,
        ),
        if (_currentIndex != 4)
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => setState(() => _currentIndex = 4),
          ),
      ],
    );
  }

  void _showNotifications() {
    // Implémentez la logique des notifications
  }
}
