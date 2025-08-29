import 'dart:core';

import 'package:app_news/models/video_item.dart';
import 'package:app_news/screens/video/widgets/video_tile.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:flutter/material.dart';

class VideoGridList extends StatelessWidget {
  final List<VideoItem> videos;
  final bool isGridView;
  final Function(String) onVideoTap;

  const VideoGridList({
    super.key,
    required this.videos,
    required this.isGridView,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return isGridView
        ? GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 16 / 9,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: videos.length,
            itemBuilder: (context, index) => VideoTile(
              video: videos[index],
              onTap: () => onVideoTap(videos[index].link),
              isGrid: isGridView,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            itemBuilder: (context, index) => VideoTile(
              video: videos[index],
              onTap: () => onVideoTap(videos[index].link),
              isGrid: isGridView,
            ),
          );
  }
}

class VideoDeSite extends StatelessWidget {
  final Future<List<VideoItem>> videosFuture;
  final bool isGridView;
  final void Function(String link, List<VideoItem> videos) playVideo;

  final String nomSite;

  const VideoDeSite({
    super.key,
    required this.videosFuture,
    required this.isGridView,
    required this.playVideo,
    required this.nomSite,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VideoItem>>(
      future: videosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        }

        final videos = snapshot.data ?? [];

        if (videos.isEmpty) {
          return const Center(child: Text('Aucune vidéo disponible'));
        }

        return Column(
          children: [
            // Affichage de la liste de vidéos
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: AppColors.secondaryColor),

              child: Center(
                child: Text(
                  'Vidéos de $nomSite',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 8),
            VideoGridList(
              videos: videos,
              isGridView: isGridView,
              onVideoTap: (link) =>
                  playVideo(link, videos), // Callback pour jouer la vidéo
            ),
          ],
        );
      },
    );
  }
}
