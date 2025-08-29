import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_news/main.dart';
import 'package:app_news/models/video_item.dart';
import 'package:app_news/screens/notification/notifications_page.dart';
import 'package:app_news/services/article_service.dart';
import 'package:app_news/services/video_service.dart';
import 'package:app_news/utils/helper/hive_box.dart';
import 'package:app_news/utils/onboarding_util/topic_urls.dart';
import 'package:app_news/widgets/news_webview.dart';
import 'package:app_news/widgets/youtube_player_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:app_news/models/notification_item.dart';
import 'package:app_news/utils/helper/notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final ArticleService _homeService = ArticleService();
  factory NotificationService() => _instance;
  NotificationService._internal();
 

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<List<NotificationItem>>
  _notificationsStreamController = StreamController.broadcast();

  // Channel IDs
  static const String _generalChannelId = 'high_importance_channel';
  static const String _youtubeChannelId = 'youtube_channel';
  static const String _articlesChannelId = 'articles_channel';

  Stream<List<NotificationItem>> get notificationsStream =>
      _notificationsStreamController.stream;

  // Initialization
  Future<void> initialize() async {
    if (Platform.isIOS && !kIsWeb) {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;
      final isPhysicalDevice = iosInfo.isPhysicalDevice;

      if (!isPhysicalDevice) {
        debugPrint('Notifications not supported on iOS simulator');
        return;
      }
    }
    _initStream();
    await _configureNotificationChannels();
    await _initializeLocalNotifications();
    await setupFirebaseMessaging();
    await _loadInitialNotifications();
  }

  Future<void> _loadInitialNotifications() async {
    try {
      final notifications = await getAllNotifications();
      _notificationsStreamController.add(notifications);
    } catch (e) {
      debugPrint('Error loading initial notifications: $e');
    }
  }

  // Configuration des canaux de notification
  Future<void> _configureNotificationChannels() async {
    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          _generalChannelId,
          'Important Notifications',
          importance: Importance.max,
          playSound: true,
          showBadge: true,
        );

    const AndroidNotificationChannel youtubeChannel =
        AndroidNotificationChannel(
          _youtubeChannelId,
          'YouTube Videos',
          importance: Importance.high,
          playSound: true,
          showBadge: true,
        );

    const AndroidNotificationChannel articlesChannel =
        AndroidNotificationChannel(
          _articlesChannelId,
          'News Articles',
          importance: Importance.high,
          playSound: true,
        );

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(generalChannel);
    await androidPlugin?.createNotificationChannel(youtubeChannel);
    await androidPlugin?.createNotificationChannel(articlesChannel);
  }

  // Initialisation des notifications locales
  Future<void> _initializeLocalNotifications() async {
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    await _notificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // Configuration de Firebase Messaging
  Future<void> setupFirebaseMessaging() async {
    await _requestNotificationPermissions();
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOpenedApp);

    if (Platform.isIOS) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint('APNS Token: $apnsToken');

      if (apnsToken == null) {
        debugPrint('APNS token not available yet, retrying...');
        await Future.delayed(const Duration(seconds: 2));
        return setupFirebaseMessaging();
      }
    }

    final String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
  }

  // Demande des permissions
  Future<void> _requestNotificationPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permissions');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permissions');
    } else {
      debugPrint('User declined or has not accepted notification permissions');
    }
  }

  // Gestion des messages en foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Handling a foreground message: ${message.messageId}');
    await _saveNotification(message);
    await _showLocalNotification(message);
  }

  // Sauvegarde des notifications
  Future<void> _saveNotification(RemoteMessage message) async {
    debugPrint('🔄 Saving notification: ${message.messageId}');

    try {
      final box = Hive.isBoxOpen('notifications')
          ? Hive.box<NotificationItem>('notifications')
          : await Hive.openBox<NotificationItem>('notifications');

      final notification = NotificationItem(
        id:
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? 'Nouvelle notification',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
        date: DateTime.now(),
        isRead: false,
        type: message.data['type'] ?? 'general',
        link: message.data['url'] ?? message.data['link'],
      );

      await box.put(notification.id, notification);
      debugPrint('✅ Notification saved: ${notification.title}');

      await refreshNotifications(); // ✅ simplification ici
    } catch (e) {
      debugPrint('❌ Error saving notification: $e');
    }
  }

  Future<void> saveLocalNotification(NotificationItem item) async {
    final box = Hive.isBoxOpen('notifications')
        ? Hive.box<NotificationItem>('notifications')
        : await Hive.openBox<NotificationItem>('notifications');

    await box.put(item.id, item);
    await refreshNotifications();
  }

  // Affichage des notifications locales
  Future<void> _showLocalNotification(RemoteMessage message) async {
    String channelId = _generalChannelId;
    String channelName = 'Important Notifications';

    if (message.data['type'] == 'youtube') {
      channelId = _youtubeChannelId;
      channelName = 'YouTube Videos';
    } else if (message.data['type'] == 'article') {
      channelId = _articlesChannelId;
      channelName = 'News Articles';
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      styleInformation: BigTextStyleInformation(
        message.notification?.body ?? '',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: jsonEncode({
        'id': message.messageId ?? '',
        'type': message.data['type'] ?? 'general',
        'link': message.data['url'] ?? '',
      }),
    );
  }

  // 1. D'abord, ajoutez cette nouvelle méthode publique dans NotificationService
  Future<void> showTestNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    required String link,
  }) async {
    final payload = jsonEncode({
      'id': id.toString(),
      'type': type,
      'link': link,
    });

    String channelId = _generalChannelId;
    String channelName = 'Important Notifications';

    if (type == 'youtube') {
      channelId = _youtubeChannelId;
      channelName = 'YouTube Videos';
    } else if (type == 'article') {
      channelId = _articlesChannelId;
      channelName = 'News Articles';
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // Navigation unifiée vers le contenu
  Future<void> _navigateToContent(String? link, String type) async {
    if (link == null || navigatorKey.currentState == null) return;

    navigatorKey.currentState!.popUntil((route) => route.isFirst);

    // Pause légère pour éviter les conflits de navigation
    await Future.delayed(const Duration(milliseconds: 100));

    if (type == 'youtube') {
      // Créer une playlist factice avec une seule vidéo
      final videoList = [
        VideoItem(title: "Vidéo depuis notification", link: link),
      ];

      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) =>
              YoutubePlaylistPlayerScreen(videos: videoList, initialIndex: 0),
        ),
      );
    } else {
      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => NewsWebviewApp(newsURL: link)),
      );
    }
  }

  // Gestion du clic sur notification locale
  void _onNotificationTap(NotificationResponse response) async {
    debugPrint('🔄 Notification tap: ${response.payload}');

    if (response.payload == null) return;

    try {
      final data = jsonDecode(response.payload!);
      final id = data['id'];
      final link = data['link'];
      final type = data['type'];

      if (id != null) {
        await markNotificationAsRead(id);
      }

      // 👉 Ouvre la page de notifications
      await _goToNotificationsPage();

      await _navigateToContent(link, type);
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  // Gestion de l'ouverture de l'app via notification Firebase
  Future<void> handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint(
      '📬 Notification tap depuis barre système: ${message.messageId}',
    );

    try {
      // Sauvegarder la notification si ce n’est pas déjà fait
      await _saveNotification(message);

      // Marquer comme lue
      await markNotificationAsRead(message.messageId);

      // Extraire les données
      final data = message.data;
      final link = data['url'] ?? data['link'];
      final type = data['type'] ?? 'general';

      // 👉 Ouvre la page de notifications
      await _goToNotificationsPage();

      if (link != null && link.toString().isNotEmpty) {
        await _navigateToContent(link, type);
      } else {
        debugPrint('⚠️ Aucun lien valide trouvé dans la notification');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du traitement du tap sur notification: $e');
    }
  }

  // Handler pour les messages en background
  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    try {
      await Firebase.initializeApp();
      // ✅ Utilisez l'instance singleton directement
      await _instance._saveNotification(message);
      await _instance._showLocalNotification(message);
    } catch (e) {
      debugPrint('❌ Background handler error: $e');
    }
  }

  // Vérification des nouvelles vidéos YouTube depuis tous les canaux
  Future<bool> checkNewYoutubeVideos() async {
    final box = await Hive.openBox('last_items');
    bool hasNewVideos = false;

    for (final entry in TopicUrls.videoUrls.entries) {
      final topicKey = entry.key;
      final feedUrl = entry.value;

      // Skip les URLs vides
      if (feedUrl.isEmpty) continue;

      try {
        // ✅ UTILISATION DE VideoService EXISTANT
        final List<VideoItem> videos = await VideoService.fetchVideos(feedUrl);

        if (videos.isEmpty) continue;

        final latestVideo = videos.first;
        final videoUrl = latestVideo.link;
        final videoTitle = latestVideo.title;

        final lastSeen = box.get(
          'last_video_${topicKey}_url',
          defaultValue: '',
        );

        if (videoUrl != lastSeen && videoUrl.isNotEmpty) {
          final item = NotificationItem(
            id: '${topicKey}_${DateTime.now().millisecondsSinceEpoch}',
            title: '[${topicKey}] Nouvelle vidéo disponible',
            body: videoTitle,
            payload: jsonEncode({
              'url': videoUrl,
              'type': 'youtube',
              'source': topicKey,
            }),
            date: DateTime.now(),
            isRead: false,
            type: 'youtube',
            link: videoUrl,
          );

          await saveLocalNotification(item);

          await _showLocalNotification(
            RemoteMessage(
              notification: RemoteNotification(
                title: item.title,
                body: item.body,
              ),
              data: {
                'url': item.link ?? '',
                'type': item.type,
                'id': item.id,
                'source': topicKey,
              },
            ),
          );

          await box.put('last_video_${topicKey}_url', videoUrl);
          hasNewVideos = true;
          debugPrint('✅ Nouvelle vidéo détectée pour $topicKey: $videoTitle');
        }
      } catch (e) {
        debugPrint('❌ Error checking YouTube videos for $topicKey: $e');
      }
    }

    return hasNewVideos;
  }

  // Vérification des nouveaux articles depuis tous les flux RSS
  Future<bool> checkNewArticlesFromAllTopics() async {
    final box = await Hive.openBox('last_items');
    bool hasNewArticle = false;

    for (final entry in TopicUrls.urls.entries) {
      final topicKey = entry.key;
      final rssUrl = entry.value;

      try {
        // ✅ UTILISATION DE HomeService EXISTANT
        final RssFeed feed = await _homeService.fetchFeedWithRetry(rssUrl);

        if (feed.items == null || feed.items!.isEmpty) continue;

        final latestItem = feed.items!.first;
        final title = latestItem.title ?? 'Sans titre';
        final link = latestItem.link ?? '';

        final lastSeen = box.get(
          'last_article_${topicKey}_url',
          defaultValue: '',
        );

        if (link != lastSeen && link.isNotEmpty) {
          final item = NotificationItem(
            id: '${topicKey}_${DateTime.now().millisecondsSinceEpoch}',
            title: '[${topicKey}] $title',
            body: title,
            payload: jsonEncode({
              'url': link,
              'type': 'article',
              'source': topicKey,
            }),
            date: DateTime.now(),
            isRead: false,
            type: 'article',
            link: link,
          );

          await saveLocalNotification(item);

          await _showLocalNotification(
            RemoteMessage(
              notification: RemoteNotification(
                title: item.title,
                body: item.body,
              ),
              data: {
                'url': item.link ?? '',
                'type': item.type,
                'id': item.id,
                'source': topicKey,
              },
            ),
          );

          await box.put('last_article_${topicKey}_url', link);
          hasNewArticle = true;
          debugPrint('✅ Nouvel article détecté pour $topicKey: $title');
        }
      } catch (e) {
        debugPrint('❌ Error checking $topicKey: $e');
      }
    }

    return hasNewArticle;
  }

  // Vérification périodique du nouveau contenu
  Future<void> checkForNewContent() async {
    try {
      final hasNewVideos = await checkNewYoutubeVideos();
      final hasNewArticles = await checkNewArticlesFromAllTopics();

      if (hasNewVideos || hasNewArticles) {
        debugPrint('🎉 Nouveau contenu disponible - notifications envoyées');
      } else {
        debugPrint('📭 Aucun nouveau contenu détecté');
      }
    } catch (e) {
      debugPrint('❌ Error checking for new content: $e');
    }
  }

  // Marquer une notification comme lue
  Future<void> markNotificationAsRead(String? messageId) async {
    if (messageId == null) return;

    final box = await Hive.openBox<NotificationItem>('notifications');
    final notification = box.values.cast<NotificationItem?>().firstWhere(
      (n) => n?.id == messageId,
      orElse: () => null,
    );

    if (notification != null) {
      notification.isRead = true;
      await notification.save();
    }

    await refreshNotifications();
    _emitNotifications();
  }

  // Obtenir le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    final box = await Hive.openBox<NotificationItem>('notifications');

    final unreadCount = box.values.where((n) => !n.isRead).length;

    return unreadNotificationCount.value = unreadCount;
  }

  void _emitNotifications() {
    final box = Hive.box<NotificationItem>('notifications');
    final notifications = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    _notificationsStreamController.add(notifications);
  }

  // Obtenir toutes les notifications
  Future<List<NotificationItem>> getAllNotifications() async {
    try {
      final box = await _getNotificationBox();
      return box.values.toList().reversed.toList();
    } catch (e) {
      debugPrint('❌ Erreur getAllNotifications: $e');
      return [];
    }
  }

  Future<Box<NotificationItem>> _getNotificationBox() async {
    return await Hive.isBoxOpen('notifications')
        ? Hive.box<NotificationItem>(HiveBoxes.notifications)
        : await Hive.openBox<NotificationItem>('notifications');
  }

  // Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    for (var notification in box.values) {
      notification.isRead = true;
      await notification.save();
    }

    await refreshNotifications();
    _emitNotifications();
  }

  Future<void> deleteNotification(String id) async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    await box.delete(id);
    await refreshNotifications();
    _emitNotifications();
  }

  void dispose() {
    _notificationsStreamController.close();
  }

  // Supprimer toutes les notifications
  Future<void> clearAllNotifications() async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    await box.clear();
    await box.compact();
    await refreshNotifications();
    _emitNotifications();
  }

  void _initStream() async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    _notificationsStreamController.add(box.values.toList().reversed.toList());
  }

  Future<void> _goToNotificationsPage() async {
    if (navigatorKey.currentState == null) return;

    navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => const NotificationsPage()),
    );
  }

  Future<void> refreshNotifications() async {
    try {
      final box = await Hive.isBoxOpen('notifications')
          ? Hive.box<NotificationItem>('notifications')
          : await Hive.openBox<NotificationItem>('notifications');

      final unreadCount = box.values.where((n) => !n.isRead).length;
      unreadNotificationCount.value = unreadCount;

      _emitNotifications(); // ← UTILISATION ICI
    } catch (e) {
      debugPrint('❌ Erreur refreshNotifications: $e');
    }
  }
}
