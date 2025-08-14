import 'dart:async';
import 'dart:convert';
import 'package:app_news/models/notification_item.dart';
import 'package:app_news/screens/favorite/favorites_page.dart';
import 'package:app_news/screens/profil/settings_screen.dart';
import 'package:app_news/screens/video/videos_and_playlists_page.dart';
import 'package:app_news/screens/home/home_content.dart';
import 'package:app_news/screens/main_navigation_screen.dart';
import 'package:app_news/screens/notification/notifications_page.dart';
import 'package:app_news/screens/profil/profile_page.dart';
import 'package:app_news/screens/search/search_page.dart';
import 'package:app_news/screens/profil/profil_screen.dart';
import 'package:app_news/services/notification_service.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/helper/notifier.dart';
import 'package:app_news/widgets/generic_app_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _unreadNotificationsCount = 0;
  Timer? _contentCheckTimer;
  late StreamSubscription<List<NotificationItem>> _notificationsStreamSubscription;
  final NotificationService _notificationService = NotificationService();

  final List<Widget> _screens = [
    const HomeContent(),
    const SearchPage(),
    const VideosAndPlaylistsPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _setupContentChecker();
    _updateUnreadCount();
    _notificationService.checkForNewContent();

    // Écoute des changements dans la liste des notifications
    _notificationsStreamSubscription =
        _notificationService.notificationsStream.listen((notifications) {
      final unreadCount = notifications.where((n) => !n.isRead).length;
      unreadNotificationCount.value = unreadCount;
      if (mounted) {
        setState(() {
          _unreadNotificationsCount = unreadCount;
        });
      }
    });
  }

  @override
  void dispose() {
    _notificationsStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> _updateUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() => _unreadNotificationsCount = count);
    }
  }

  void _setupContentChecker() {
    Timer.periodic(const Duration(minutes: 30), (_) {
      _notificationService.checkForNewContent();
    });
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  Future<void> _showNotificationsPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );

    if (result == true) {
      _updateUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: _currentIndex != 1 ? _buildAppBar() : null,
      body: _screens[_currentIndex],
      bottomNavigationBar: MainNavigationScreen(
        currentIndex: _currentIndex,
        backgroundColor: AppColors.primaryColor,
        onTap: _onTabTapped,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return GenericAppBar(
      title: _getTitle(),
      backgroundColor: AppColors.primaryColor,
      actions: [
        if (_currentIndex != 1)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _onTabTapped(1),
          ),
        _buildNotificationIcon(),
        if (_currentIndex != 4)
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
        if(_currentIndex == 4)
        IconButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ), 
          icon: const Icon(Icons.settings),
          )
      ],
    );
  }

  Widget _buildNotificationIcon() {
    return ValueListenableBuilder<int>(
      valueListenable: unreadNotificationCount,
      builder: (context, count, _) {
        return Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: _showNotificationsPage,
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: IgnorePointer(
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Text(
                      count.toString(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String _getTitle() {
    const titles = ['Accueil', 'Recherche', 'Vidéos', 'Favoris', 'Profil'];
    return titles[_currentIndex];
  }
}
