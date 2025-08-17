import 'package:app_news/models/notification_item.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/news_webview.dart';
import 'package:flutter/material.dart';

class NotificationWidget extends StatelessWidget {
  final NotificationItem notification;

  const NotificationWidget({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final link = notification.link ?? '';
    final isVideo = link.contains("youtube.com") || link.contains("youtu.be");

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: notification.title,
            fontSize: 16.0,
            color: Colors.black,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isVideo ? Icons.videocam : Icons.article,
                color: isVideo ? Colors.redAccent : Colors.blueGrey,
                size: 18,
              ),
              const SizedBox(width: 6),
              AppText(
                text: '${notification.date.day}/${notification.date.month}/${notification.date.year}',
                fontSize: 12.0,
                color: AppColors.blackColor.withOpacity(0.6),
              ),
              const Spacer(),
              Container(
                width: 100,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  onPressed: () {
                    if (Uri.tryParse(link)?.hasScheme == true) {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => NewsWebviewApp(newsURL: link),
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lien non valide pour cette notification')),
                      );
                    }
                  },
                  child: const AppText(
                    text: "V I S I T",
                    fontSize: 12.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}
