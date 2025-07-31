import 'package:app_news/models/notification_item.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/helper/notifier.dart';
import 'package:app_news/widgets/NotificationWidget.dart';
import 'package:app_news/widgets/news_webview.dart';
import 'package:app_news/widgets/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Box<NotificationItem> _notificationsBox;
  List<NotificationItem> _notifications = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _notificationsBox = await Hive.openBox<NotificationItem>('notifications');
    final all = _notificationsBox.values.toList().reversed.toList();
    setState(() {
      _notifications = all;
    });
    // Met à jour le compteur global
    final count = all.where((n) => !n.isRead).length;
    unreadNotificationCount.value = count;
  }

  Future<void> _clearAllNotifications() async {
    await _notificationsBox.clear();
    setState(() => _notifications.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearAllNotifications,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('Aucune notification'))
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return Dismissible(
                  key: Key(notification.id),
                  onDismissed: (direction) async {
                    await _notificationsBox.deleteAt(index);
                    setState(() => _notifications.removeAt(index));
                  },
                  background: Container(color: Colors.red),
                  child: InkWell(
                    onTap: () => _handleNotificationTap(notification),
                    child: NotificationWidget(notification: notification),
                  ),
                );
              },
            ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) async {
    if (!notification.isRead) {
      notification.isRead = true;
      await notification.save(); // ← Sauvegarder dans Hive

      unreadNotificationCount.value = unreadNotificationCount.value - 1;

      // Mettre à jour le compteur
      final unreadCount = _notificationsBox.values
          .where((n) => !n.isRead)
          .length;
      unreadNotificationCount.value = unreadCount;
      // setState(() {}); // Pour rafraîchir la UI
    }

    final link = notification.link;
    final type = notification.type;

    if (link != null && Uri.tryParse(link)?.hasAbsolutePath == true) {
      if (type == 'video') {
        final videoId = YoutubePlayer.convertUrlToId(link);
        if (videoId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => YoutubePlayerScreen(videoId: videoId),
            ),
          );
        } else {
          _showNotificationDialog(notification);
        }
      } else if (type == 'article') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewsWebviewApp(newsURL: link)),
        );
      } else {
        _showNotificationDialog(notification);
      }
    } else {
      _showNotificationDialog(notification);
    }

    // 🔔 Optionnel : notifier une autre partie de l'app (ex. compteur badge)
    // NotificationService.updateBadgeCount(); ← à définir
  }

  void _showNotificationDialog(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
