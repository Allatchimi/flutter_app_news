import 'package:app_news/api/youtube_api_service.dart';
import 'package:app_news/models/playlist_model.dart';
import 'package:app_news/models/video_item.dart';
import 'package:app_news/widgets/video_tile.dart';
import 'package:app_news/widgets/youtube_player_flutter.dart';
import 'package:flutter/material.dart';

class PlaylistVideosPage extends StatelessWidget {
  final Playlist playlist;
  final String playlistId;

  const PlaylistVideosPage({
    super.key,
    required this.playlist,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(playlist.title)),
      body: FutureBuilder<List<VideoItem>>(
        future: YoutubeApiService.getPlaylistVideos(
          playlistUrl: playlist.url,
          playlistId: playlist.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          }
          final videos = snapshot.data!;
          return ListView.builder(
            itemCount: videos.length,
            itemBuilder: (context, index) {
              final video = videos[index];
              return VideoTile(
                video: video,
                onTap: () => _navigateToPlayer(context, video.link),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToPlayer(BuildContext context, String videoUrl) {
    final videoId = Uri.parse(videoUrl).queryParameters['v'];
    if (videoId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerScreen(videoId: videoId),
        ),
      );
    }
  }
}