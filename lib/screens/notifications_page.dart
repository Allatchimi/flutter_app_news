import 'package:app_news/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app_news/models/notification_item.dart';
import 'package:app_news/services/notification_service.dart';
import 'package:app_news/widgets/news_webview.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<NotificationItem>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _notificationsFuture = NotificationService().getAllNotifications();
  }

  void _markAsReadAndNavigate(NotificationItem notification) async {
    await NotificationService().markNotificationAsRead(notification.id);
    if (notification.link != null && notification.link!.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NewsWebviewApp(newsURL: notification.link!),
        ),
      );
    }
  }

  void _deleteNotification(String id) async {
    await NotificationService().deleteNotification(id);
    setState(() {
      _notificationsFuture = NotificationService().getAllNotifications();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification supprimée')),
    );
  }

  void _markAllAsRead() async {
    await NotificationService().markAllAsRead();
    setState(() {
      _notificationsFuture = NotificationService().getAllNotifications();
    });
  }

  void _clearAll() async {
    await NotificationService().clearAllNotifications();
    setState(() {
      _notificationsFuture = NotificationService().getAllNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: "Tout marquer comme lu",
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: "Tout supprimer",
            onPressed: _clearAll,
          ),
        ],
      ),
      body: FutureBuilder<List<NotificationItem>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune notification disponible."));
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final notif = notifications[index];

              return ListTile(
                tileColor: notif.isRead ? null : Colors.blue.withOpacity(0.05),
                leading: Icon(
                  notif.type == 'youtube'
                      ? Icons.ondemand_video
                      : notif.type == 'article'
                          ? Icons.article
                          : Icons.notifications,
                  color: notif.isRead ? Colors.grey : Colors.red,
                ),
                title: Text(
                  notif.title,
                  style: TextStyle(
                    fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notif.body),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!notif.isRead)
                      const Icon(Icons.circle, size: 8, color: Colors.red),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _deleteNotification(notif.id),
                      tooltip: "Supprimer",
                    ),
                  ],
                ),
                onTap: () => _markAsReadAndNavigate(notif),
              );
            },
          );
        },
      ),
    );
  }
}
