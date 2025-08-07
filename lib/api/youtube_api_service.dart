import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:app_news/models/playlist_model.dart';
import 'package:app_news/models/video_item.dart';

class YoutubeApiService {
  //static const String _baseUrl = "http://127.0.0.1:8000";
  static const String _baseUrl = 'https://backend-apps-news.onrender.com';
  static const Duration _cacheDuration = Duration(hours: 6);
  static const String _cacheBoxName = 'youtube_cache';

  // ► Méthodes publiques
  // ---------------------------------------------------------------------------

  /// Récupère les playlists (avec cache)
  static Future<List<Playlist>> getPlaylists() async {
    final box = await _openCacheBox();
    final cachedData = _getCachedPlaylists(box);

    // 1. Retourne le cache si valide
    if (_isCacheValid(cachedData.playlists, cachedData.lastUpdate)) {
      return cachedData.playlists!;
    }

    // 2. Sinon, appelle l'API et met à jour le cache
    try {
      final remotePlaylists = await _fetchRemotePlaylists();
      await _updateCache(box, remotePlaylists);
      return remotePlaylists;
    } catch (e) {
      // 3. Fallback au cache si disponible (même expiré)
      if (cachedData.playlists != null) return cachedData.playlists!;
      rethrow;
    }
  }

  /// Récupère les vidéos d'une playlist (avec cache)
  static Future<List<VideoItem>> getPlaylistVideos({
    required String playlistUrl,
    required String playlistId,
  }) async {
    final box = await _openCacheBox();
    final cachedData = _getCachedVideos(box, playlistId);

    // 1. Si cache valide
    if (_isCacheValid(cachedData.videos, cachedData.lastUpdate)) {
      return cachedData.videos!;
    }

    // 2. Appel API
    try {
      final remoteVideos = await _fetchRemotePlaylistVideos(playlistUrl);
      await _updateVideoCache(box, playlistId, remoteVideos);
      return remoteVideos;
    } catch (e) {
      // 3. Fallback au cache même expiré
      if (cachedData.videos != null) return cachedData.videos!;
      rethrow;
    }
  }
  
  // ► Méthodes privées - Cache
  // ---------------------------------------------------------------------------

  static Future<Box> _openCacheBox() async {
    return await Hive.openBox(_cacheBoxName);
  }

  static ({List<Playlist>? playlists, DateTime? lastUpdate})
  _getCachedPlaylists(Box box) {
    return (
      playlists: box
          .get('playlists')
          ?.map<Playlist>((e) => Playlist.fromJson(Map.from(e)))
          .toList(),
      lastUpdate: box.get('lastUpdatePlaylists') as DateTime?,
    );
  }

  static ({List<VideoItem>? videos, DateTime? lastUpdate}) _getCachedVideos(
    Box box,
    String playlistId,
  ) {
    final cacheKey = 'videos_$playlistId';
    return (
      videos: box
          .get(cacheKey)
          ?.map<VideoItem>((e) => VideoItem.fromJson(Map.from(e)))
          .toList(),
      lastUpdate: box.get('${cacheKey}_lastUpdate') as DateTime?,
    );
  }

  static bool _isCacheValid<T>(T? data, DateTime? lastUpdate) {
    return data != null &&
        lastUpdate != null &&
        DateTime.now().difference(lastUpdate) < _cacheDuration;
  }

  static Future<void> _updateCache(Box box, List<Playlist> playlists) async {
    await box.putAll({
      'playlists': playlists.map((e) => e.toJson()).toList(),
      'lastUpdatePlaylists': DateTime.now(),
    });
  }

  static Future<void> _updateVideoCache(
    Box box,
    String playlistId,
    List<VideoItem> videos,
  ) async {
    final cacheKey = 'videos_$playlistId';
    await box.putAll({
      cacheKey: videos.map((e) => e.toJson()).toList(),
      '${cacheKey}_lastUpdate': DateTime.now(),
    });

  }

  // ► Méthodes privées - Requêtes réseau
  // ---------------------------------------------------------------------------

  static Future<List<Playlist>> _fetchRemotePlaylists() async {
    final response = await http.get(Uri.parse("$_baseUrl/playlists"));
    _validateResponse(response);

    final data = jsonDecode(response.body);
    return (data['playlists'] as List)
        .map((e) => Playlist.fromJson(e))
        .toList();
  }

  static Future<List<VideoItem>> _fetchRemotePlaylistVideos(
    String playlistUrl,
  ) async {
    final uri = Uri.parse(
      "$_baseUrl/playlist_videos?url=${Uri.encodeComponent(playlistUrl)}",
    );
    final response = await http.get(uri);
    _validateResponse(response);

    final data = jsonDecode(response.body);

    if (data['videos'] == null) {
      throw Exception('Format de réponse invalide: clé "videos" manquante');
    }

    return (data['videos'] as List).map((e) {
      try {
        return VideoItem.fromJson(e);
      } catch (e) {
        throw Exception('Format video invalide');
      }
    }).toList();
  }

  static void _validateResponse(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception("Erreur HTTP ${response.statusCode}: ${response.body}");
    }
  }
}
