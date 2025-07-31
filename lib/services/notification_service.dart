import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_news/main.dart';
import 'package:app_news/widgets/news_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:app_news/models/notification_item.dart';
import 'package:app_news/utils/helper/notifier.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:device_info_plus/device_info_plus.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Channel IDs
  static const String _generalChannelId = 'high_importance_channel';
  static const String _youtubeChannelId = 'youtube_channel';
  static const String _articlesChannelId = 'articles_channel';

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
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _saveNotification(message);
    });

    await _configureNotificationChannels();
    await _initializeLocalNotifications();
    await _setupFirebaseMessaging();
  }

  // Configuration des canaux de notification
  Future<void> _configureNotificationChannels() async {
    // Canal principal
    const AndroidNotificationChannel generalChannel =
        AndroidNotificationChannel(
          _generalChannelId,
          'Important Notifications',
          importance: Importance.max,
          playSound: true,
          showBadge: true,
        );

    // Canal pour les vidéos YouTube
    const AndroidNotificationChannel youtubeChannel =
        AndroidNotificationChannel(
          _youtubeChannelId,
          'YouTube Videos',
          importance: Importance.high,
          playSound: true,
          showBadge: true,
        );

    // Canal pour les articles
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
  Future<void> _setupFirebaseMessaging() async {
    await _requestNotificationPermissions();

    // Spécifique à iOS - attendre le token APNS
    if (Platform.isIOS) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint('APNS Token: $apnsToken');

      if (apnsToken == null) {
        debugPrint('APNS token not available yet, retrying...');
        await Future.delayed(const Duration(seconds: 2));
        return _setupFirebaseMessaging(); // Réessayer
      }
    }

    // Gestion des messages selon l'état de l'app
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Récupération du token FCM
    final String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');
  }

  // Demande des permissions
  Future<void> _requestNotificationPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true, // Permissions provisoires pour iOS
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

  // Sauvegarde des notifications dans Hive depuis Firebase
  Future<void> _saveNotification(RemoteMessage message) async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    await box.add(
      NotificationItem(
        id:
            message.messageId ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        title: message.notification?.title ?? 'Nouvelle notification',
        body: message.notification?.body ?? '',
        payload: message.data.toString(),
        date: DateTime.now(),
        isRead: false,
        type: message.data['type'] ?? 'general',
      ),

    );
       // Mise à jour dynamique du compteur
      final unreadCount = box.values.where((n) => !n.isRead).length;
      unreadNotificationCount.value = unreadCount;
  }

  // Sauvage des notifications locales dans Hive
  Future<String> saveLocalNotification({
    required String title,
    required String body,
    String payload = '',
    String type = 'general',
    String? link,
  }) async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final notification = NotificationItem(
      id: id,
      title: title,
      body: body,
      payload: payload,
      date: DateTime.now(),
      isRead: false,
      type: type,
      link: link,
      imageUrl: null,
    );

    await box.put(id, notification);
    return id;
  }

  // Affichage des notifications locales
  Future<void> _showLocalNotification(RemoteMessage message) async {
    String channelId = _generalChannelId;
    String? channelName = 'Important Notifications';

    // Déterminer le canal en fonction du type de notification
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

  // Gestion du clic sur notification
  void _onNotificationTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null) return;

    try {
      final data = jsonDecode(payload);
      final id = data['id'];
      final link = data['link'];
      final type = data['type'];

      if (id != null) {
        await _markNotificationAsRead(id);
      }

      if (link != null) {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => NewsWebviewApp(newsURL: link)),
        );
      }
    } catch (e) {
      debugPrint('Erreur de décodage payload: $e');
    }
  }

  // Gestion de l'ouverture de l'app via notification
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    debugPrint('App opened via notification: ${message.messageId}');
    await _markNotificationAsRead(message.messageId);
    // TODO: Implémenter la navigation vers l'écran approprié
  }

  // Handler pour les messages en background
  @pragma('vm:entry-point')
  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await NotificationService()._handleForegroundMessage(message);
  }

  // Vérification des nouvelles vidéos YouTube
  Future<bool> checkNewYoutubeVideos() async {
    const rssUrl =
        "https://www.youtube.com/feeds/videos.xml?channel_id=UC-lHJZR3Gqxm24_Vd_AJ5Yw";
    try {
      final response = await http.get(Uri.parse(rssUrl));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final latestEntry = document.findAllElements('entry').first;

        final videoUrl =
            latestEntry.findElements('link').first.getAttribute('href') ?? '';
        final videoTitle = latestEntry.findElements('title').first.text;

        final box = await Hive.openBox('last_items');
        final lastSeen = box.get('last_video_url', defaultValue: '');

        if (videoUrl != lastSeen) {
          await _showLocalNotification(
            RemoteMessage(
              notification: RemoteNotification(
                title: 'Nouvelle vidéo disponible',
                body: videoTitle,
              ),
              data: {'url': videoUrl, 'type': 'youtube'},
            ),
          );
          await box.put('last_video_url', videoUrl);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking YouTube videos: $e');
    }
    return false;
  }

  // Vérification des nouveaux articles
  Future<bool> checkNewArticles() async {
    const newsRss =
        "https://news.google.com/rss/headlines/section/topic/WORLD?ceid=US:EN&hl=en&gl=US"; // À remplacer par votre flux RSS

    try {
      final response = await http.get(Uri.parse(newsRss));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final latestItem = document.findAllElements('item').first;
        final title = latestItem.findElements('title').first.text;
        final link = latestItem.findElements('link').first.text;

        final box = await Hive.openBox('last_items');
        final lastSeen = box.get('last_article_url', defaultValue: '');

        if (link != lastSeen) {
          await _showLocalNotification(
            RemoteMessage(
              notification: RemoteNotification(
                title: 'Nouvel article disponible',
                body: title,
              ),
              data: {'url': link, 'type': 'article'},
            ),
          );
          await box.put('last_article_url', link);
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking articles: $e');
    }
    return false;
  }

  // Vérification périodique du nouveau contenu
  Future<void> checkForNewContent() async {
    try {
      final hasNewVideos = await checkNewYoutubeVideos();
      final hasNewArticles = await checkNewArticles();

      if (hasNewVideos || hasNewArticles) {
        debugPrint('New content available and notifications sent');
      }
    } catch (e) {
      debugPrint('Error checking for new content: $e');
    }
  }

  // Marquer une notification comme lue
  Future<void> _markNotificationAsRead(String? messageId) async {
    if (messageId == null) return;

    final box = await Hive.openBox<NotificationItem>('notifications');
    final notification = box.values.cast<NotificationItem?>().firstWhere(
      (n) => n?.id == messageId,
      orElse: () => null,);

    if (notification != null) {
      notification.isRead = true;
      await notification.save();
    }
  }

  // Obtenir le nombre de notifications non lues
  Future<int> getUnreadCount() async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    return box.values.where((n) => !n.isRead).length;
  }

  // Obtenir toutes les notifications
  Future<List<NotificationItem>> getAllNotifications() async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    return box.values.toList().reversed.toList(); // Plus récentes en premier
  }

  // Marquer toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    for (var notification in box.values) {
      notification.isRead = true;
      await notification.save();
    }
  }

  // Supprimer toutes les notifications
  Future<void> clearAllNotifications() async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    await box.clear();
  }


}


