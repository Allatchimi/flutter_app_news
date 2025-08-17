import 'package:flutter/material.dart';
import '../../../models/video_item.dart';

class VideoTile extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;

  const VideoTile({super.key, required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: video.thumbnailUrl != null
            ? Image.network(video.thumbnailUrl!, width: 100, fit: BoxFit.cover)
            : const Icon(Icons.videocam, size: 40),
        title: Text(video.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(video.description!, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.play_arrow),
        onTap: onTap,
      ),
    );
  }
}
