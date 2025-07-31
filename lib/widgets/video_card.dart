// widgets/video_card.dart
import 'package:app_news/models/video_item.dart';
import 'package:flutter/material.dart';


class YoutubeVideoCard extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;

  const YoutubeVideoCard({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: video.thumbnailUrl != null
            ? Image.network(video.thumbnailUrl!, width: 60, height: 60, fit: BoxFit.cover)
            : const Icon(Icons.ondemand_video, size: 40),
        title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          video.description ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}