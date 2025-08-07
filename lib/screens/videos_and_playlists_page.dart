import 'package:app_news/screens/playlist_videos_page.dart';
import 'package:flutter/material.dart';
import 'package:app_news/api/youtube_api_service.dart';
import 'package:app_news/models/playlist_model.dart';
import 'package:app_news/models/video_item.dart';
import 'package:app_news/services/video_service.dart';
import 'package:app_news/widgets/video_tile.dart';
import 'package:app_news/widgets/playlist_tile.dart';
import 'package:app_news/widgets/youtube_player_flutter.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/widgets/generic_app_bar.dart';
import 'package:hive/hive.dart';

class VideosAndPlaylistsPage extends StatefulWidget {
  const VideosAndPlaylistsPage({super.key});

  @override
  State<VideosAndPlaylistsPage> createState() => _VideosAndPlaylistsPageState();
}

class _VideosAndPlaylistsPageState extends State<VideosAndPlaylistsPage> {
  late Future<List<VideoItem>> _videosFuture;
  late Future<List<Playlist>> _playlistsFuture;
  bool _isGridView = false;

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
      _playlistsFuture = YoutubeApiService.getPlaylists();
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

  Widget 
  _buildVideoSection(List<VideoItem> videos) {
   
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "📰 Vidéos récentes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _isGridView
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
                  onTap: () => _playVideo(videos[index].link),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: videos.length,
                itemBuilder: (context, index) => VideoTile(
                  video: videos[index],
                  onTap: () => _playVideo(videos[index].link),
                ),
              ),
      ],
    );
  }

  Widget _buildPlaylistSection(List<Playlist> playlists) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            "📂 Playlists",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        _isGridView
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: playlists.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 16 / 9,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) => PlaylistTile(
                  playlist: playlists[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistVideosPage(
                        playlist: playlists[index],
                        playlistId: playlists[index].id,
                      ),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: playlists.length,
                itemBuilder: (context, index) => PlaylistTile(
                  playlist: playlists[index],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistVideosPage(
                        playlist: playlists[index],
                        playlistId: playlists[index].id,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(
        title: "Vidéos et playlists",
        backgroundColor: AppColors.secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(forceRefresh: true), // Refresh forcé
            tooltip: "Forcer le rafraîchissement",
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
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
                  return _buildVideoSection(snapshot.data ?? []);
                },
              ),
              FutureBuilder<List<Playlist>>(
                future: _playlistsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Erreur playlists : ${snapshot.error}');
                  }
                  return _buildPlaylistSection(snapshot.data ?? []);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}