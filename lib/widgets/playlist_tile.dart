// widgets/playlist_tile.dart
import 'package:app_news/models/playlist_model.dart';
import 'package:flutter/material.dart';


class PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final VoidCallback onTap;

  const PlaylistTile({super.key, required this.playlist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(4),
      child: ListTile(
        leading: playlist.thumbnail != null
            ? Image.network(playlist.thumbnail!, width: 100, height: 60, fit: BoxFit.cover)
            : const Icon(Icons.playlist_play, size: 40),
        title: Text(playlist.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          playlist.description ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }
}
