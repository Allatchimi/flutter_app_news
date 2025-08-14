import 'package:flutter/material.dart';
import 'package:app_news/api/youtube_api_service.dart';
import 'package:app_news/models/playlist_model.dart';
import 'package:app_news/screens/video/playlist_videos_page.dart';
import 'package:app_news/widgets/playlist_tile.dart';
import 'package:hive/hive.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  late Future<List<Playlist>> _playlistsFuture;

  @override
  void initState() {
    super.initState();
    _loadPlaylists(forceRefresh: false);
  }

  Future<void> _loadPlaylists({required bool forceRefresh}) async {
    if (forceRefresh) {
      final box = await Hive.openBox('youtube_cache');
      await box.delete('playlists');
      await box.delete('lastUpdatePlaylists');
    }
    setState(() {
      _playlistsFuture = YoutubeApiService.getPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Playlists"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadPlaylists(forceRefresh: true), // Refresh forcé
            tooltip: "Forcer le rafraîchissement",
          ),
        ],
      ),
      body: FutureBuilder<List<Playlist>>(
        future: _playlistsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Erreur de chargement",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadPlaylists(forceRefresh: false),
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            );
          }

          final playlists = snapshot.data!;
          if (playlists.isEmpty) {
            return const Center(child: Text("Aucune playlist disponible"));
          }

          return RefreshIndicator(
            onRefresh: () => _loadPlaylists(forceRefresh: false), // Refresh simple
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];

                final playlistId = playlist.id; 
                return PlaylistTile(
                  playlist: playlist,

                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistVideosPage(
                        playlist: playlist,
                        playlistId: playlist.id,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}