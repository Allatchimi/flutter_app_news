import 'package:app_news/models/video_item.dart';
import 'package:app_news/screens/video/widgets/video_tile.dart';
import 'package:flutter/material.dart';

class VideoWidget extends StatelessWidget {
  final List<VideoItem> videos;
  final bool isGridView;
  final Function(String) onVideoTap;

  const VideoWidget({
    super.key,
    required this.videos,
    required this.isGridView,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "📰 ManaraTV Vidéos",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        isGridView
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videos.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 16 / 9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) => VideoTile(
                  video: videos[index],
                  onTap: () => onVideoTap(videos[index].link),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videos.length,
                itemBuilder: (context, index) => VideoTile(
                  video: videos[index],
                  onTap: () => onVideoTap(videos[index].link),
                ),
              ),
      ],
    );
  }
}
