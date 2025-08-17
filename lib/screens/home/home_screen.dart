import 'package:app_news/screens/home/widgets/home_screen_widgets.dart';
import 'package:app_news/screens/profil/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/screens/notification/notifications_page.dart';
import 'package:app_news/screens/home/home_content.dart';
import 'package:app_news/screens/search/search_page.dart';
import 'package:app_news/screens/video/videos_page.dart';
import 'package:app_news/screens/favorite/favorites_page.dart';

import 'package:app_news/services/notification_service.dart';

import 'package:app_news/utils/helper/notifier.dart';
import 'package:app_news/screens/common/main_navigation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final NotificationService _notificationService = NotificationService();
  String feedUrl = "https://manara.td/feed/";
  final List<Widget> _screens = [
    const HomeContent(),
    const SearchPage(),
    const VideosPage(),
    const FavoritesPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    
      // 1. Écoute les changements en temps réel
    _notificationService.notificationsStream.listen((notifications) {
      unreadNotificationCount.value =
          notifications.where((n) => !n.isRead).length;
    });
    // 2. Valeur initiale au lancement
    _loadInitialUnreadCount();
  }

  Future<void> _loadInitialUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    unreadNotificationCount.value = count;
  }


  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> showNotificationsPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
    if (result == true) {
      final count = await _notificationService.getUnreadCount();
      unreadNotificationCount.value = count;
    }
  }

  String _getTitle() {
    const titles = ['Accueil', 'Recherche', 'Vidéos', 'Favoris', 'Profil'];
    return titles[_currentIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: _currentIndex != 1
          ? CustomAppBar(
              title: _getTitle(),
              currentIndex: _currentIndex,
              unreadCount: unreadNotificationCount,
              onSearchTap: () => _onTabTapped(1),
              onNotificationsTap: showNotificationsPage,
            )
          : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: MainNavigationScreen(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.primaryColor,
        onTap: _onTabTapped,
      ),
    );
  }
}
