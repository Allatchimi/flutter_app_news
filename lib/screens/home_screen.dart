import 'dart:async';
import 'package:app_news/main.dart';
import 'package:app_news/models/notification_item.dart';
import 'package:app_news/screens/favorites_page.dart';
import 'package:app_news/screens/home/videos_and_playlists_page.dart';
import 'package:app_news/screens/home_content.dart';
import 'package:app_news/screens/main_navigation_screen.dart';
import 'package:app_news/screens/notifications_page.dart';
import 'package:app_news/screens/profil_screen.dart';
import 'package:app_news/screens/profile_page.dart';
import 'package:app_news/screens/search_page.dart';
import 'package:app_news/services/notification_service.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/helper/notifier.dart';
import 'package:app_news/widgets/generic_app_bar.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _unreadNotificationsCount = 0;
  late StreamSubscription _notificationSubscription;
  final NotificationService _notificationService = NotificationService();

  final List<Widget> _screens = [
    const HomeContent(),
    const SearchPage(),
    //const VideoFeedPage(),
    const VideosAndPlaylistsPage(),
    const FavoritesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _setupContentChecker();
    loadUnreadNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription.cancel();
    super.dispose();
  }
  @override
  void setState(VoidCallback fn) {
    loadUnreadNotifications();
    super.setState(fn);
  }

  Future<void> _initNotifications() async {
    await _notificationService.initialize();
    _updateUnreadCount();

    _notificationSubscription = FirebaseMessaging.onMessage.listen((message) {
      _updateUnreadCount();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleNotificationTap(message.data);
    });
  }

  void _setupContentChecker() {
    Timer.periodic(const Duration(minutes: 30), (_) {
      _notificationService.checkForNewContent();
    });
  }

  Future<void> _updateUnreadCount() async {
    final count = await _notificationService.getUnreadCount();
    if (mounted) {
      setState(() => _unreadNotificationsCount = count);
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    if (data['type'] == 'youtube') {
      setState(() => _currentIndex = 2); // Naviguer vers l'onglet Vidéos
    }
    _updateUnreadCount();
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


  void loadUnreadNotifications() async {
  final box = await Hive.openBox<NotificationItem>('notifications');
  final unreadCount = box.values.where((n) => !n.isRead).length;
  unreadNotificationCount.value = unreadCount;
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
            //onPressed: () => _onTabTapped(4),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            ),
          ),
        // Dans home_screen.dart ou main.dart
        ElevatedButton(
          onPressed: () async {
            final id = await NotificationService().saveLocalNotification(
              title: 'Titre test article',
              body: 'Ceci est une notification locale de test',
              type: 'video',
              link: 'https://example.com/article',
            );

            final payload =
                '{"id":"$id","type":"article","link":"https://example.com/article"}';

            await flutterLocalNotificationsPlugin.show(
              0,
              'Nouvelle Notification Locale',
              'Ceci est une notification locale de test locale',
              NotificationDetails(
                android: AndroidNotificationDetails(
                  'test_channel',
                  'Test Channel',
                  importance: Importance.high,
                  priority: Priority.high,
                ),
                iOS: const DarwinNotificationDetails(),
              ),
              payload: payload,
            );
          },

          child: Text('Test Notif Locale'),
        ),
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
