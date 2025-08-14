import 'package:flutter/material.dart';
import '../../models/video_item.dart';
import '../../services/video_service.dart';
import '../../widgets/video_tile.dart';
import '../../widgets/youtube_player_flutter.dart';

class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  late Future<List<VideoItem>> _videos;
  List<VideoItem> _cachedVideos = [];

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

    Future<void> _loadVideos() async {  // Changed to Future<void>
      setState(() {
        _videos = VideoService.fetchVideos().then((videos) {
          _cachedVideos = videos;
          return videos;
        });
      });
    }

  void _playVideo(String link) {
    final videoId = Uri.parse(link).queryParameters['v'] ?? '';
    if (videoId.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => YoutubePlayerScreen(videoId: videoId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lien vidéo invalide")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vidéos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVideos,
          ),
        ],
      ),
      body: FutureBuilder<List<VideoItem>>(
        future: _videos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _cachedVideos.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError && _cachedVideos.isEmpty) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          // Utiliser les données en cache si disponible, sinon les nouvelles données
          final videos = snapshot.hasData ? snapshot.data! : _cachedVideos;
          
          if (videos.isEmpty) {
            return const Center(child: Text('Aucune vidéo disponible'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await _loadVideos();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                return VideoTile(
                  video: video,
                  onTap: () => _playVideo(video.link),
                );
              },
            ),
          );
        },
      ),
    );
  }
}