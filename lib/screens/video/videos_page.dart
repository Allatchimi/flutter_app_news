import 'package:app_news/screens/video/widgets/video_widget.dart';
import 'package:flutter/material.dart';
import 'package:app_news/models/video_item.dart';
import 'package:app_news/services/video_service.dart';
import 'package:app_news/widgets/youtube_player_flutter.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/widgets/generic_app_bar.dart';
import 'package:hive/hive.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  late Future<List<VideoItem>> _videosFuture;
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadData(forceRefresh: false);
  }

  Future<void> _loadData({required bool forceRefresh}) async {
    if (forceRefresh) {
      final box = await Hive.openBox('youtube_cache');
      await box.delete('playlists');
      await box.delete('lastUpdatePlaylists');
    }
    setState(() {
      _videosFuture = VideoService.fetchVideos();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(
        title: "Les Vidéos",
        backgroundColor: AppColors.secondaryColor,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(forceRefresh: true), // Refresh forcé
            tooltip: "Forcer le rafraîchissement",
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(forceRefresh: false), // Refresh simple
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              FutureBuilder<List<VideoItem>>(
                future: _videosFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur vidéos : ${snapshot.error}');
                  }
                  return VideoWidget(
                    videos: snapshot.data ?? [],
                    isGridView: isGridView,
                    onVideoTap: _playVideo,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
