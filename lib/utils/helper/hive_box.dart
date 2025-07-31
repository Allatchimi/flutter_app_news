import 'package:app_news/models/article_model.dart';
import 'package:app_news/models/favorite_article.dart';
import 'package:app_news/models/notification_item.dart';
import 'package:app_news/models/playlist_model.dart';
import 'package:app_news/models/video_item.dart';
import 'package:hive/hive.dart';

class HiveBoxes {
  static const String playlistVideos = 'playlist_videos';
  static const String feedVideos = 'feed_videos';
  static const String favorites = 'favorites_articles';
  static const String notifications = 'notifications';
  static const String articles = 'articles';
  
  static Future<void> init() async {

     // Enregistrement des adaptateurs
    Hive.registerAdapter(FavoriteArticleAdapter());
    Hive.registerAdapter(NotificationItemAdapter());
    Hive.registerAdapter(VideoItemAdapter());
    Hive.registerAdapter(PlaylistAdapter()); // Généré automatiquement
    Hive.registerAdapter(ArticleModelAdapter());
    await Hive.openBox<VideoItem>(playlistVideos);
    await Hive.openBox<VideoItem>(feedVideos);

    // Ouverture des boîtes

      await Future.wait([
        Hive.openBox<VideoItem>(playlistVideos),
        Hive.openBox<VideoItem>(feedVideos),
        Hive.openBox<FavoriteArticle>(favorites),
        Hive.openBox<NotificationItem>(notifications),
        Hive.openBox<ArticleModel>(articles),
       
      ]);
    //await Hive.openBox<Playlist>('playlistsBox');
    // await Hive.openBox<FavoriteArticle>(favorites);
    //await Hive.openBox<NotificationItem>(notifications);
    //await Hive.openBox<VideoItem>('videos');
    //await Hive.openBox<ArticleModel>(articles);
  }
}

/*
import 'package:hive/hive.dart';
import 'package:app_news/models/article_model.dart';
import 'package:app_news/models/favorite_article.dart';
import 'package:app_news/models/notification_item.dart';
import 'package:app_news/models/playlist_model.dart';
import 'package:app_news/models/video_item.dart';

class HiveBoxManager {
  // ► Noms des boîtes
  // ---------------------------------------------------------------------------
  static const String _playlistVideos = 'playlist_videos';
  static const String _feedVideos = 'feed_videos';
  static const String _favorites = 'favorites_articles';
  static const String _notifications = 'notifications';
  static const String _articles = 'articles';
  static const String _youtubeCache = 'youtube_cache';

  // ► Getters pour accéder aux boîtes ouvertes
  // ---------------------------------------------------------------------------
  static Box<VideoItem> get playlistVideosBox => Hive.box<VideoItem>(_playlistVideos);
  static Box<VideoItem> get feedVideosBox => Hive.box<VideoItem>(_feedVideos);
  static Box<FavoriteArticle> get favoritesBox => Hive.box<FavoriteArticle>(_favorites);
  static Box<NotificationItem> get notificationsBox => Hive.box<NotificationItem>(_notifications);
  static Box<ArticleModel> get articlesBox => Hive.box<ArticleModel>(_articles);
  static Box get youtubeCacheBox => Hive.box(_youtubeCache);

  // ► Initialisation de toutes les boîtes
  // ---------------------------------------------------------------------------
  static Future<void> init() async {
    // Enregistrement des adaptateurs
    Hive.registerAdapter(VideoItemAdapter());
    Hive.registerAdapter(FavoriteArticleAdapter());
    Hive.registerAdapter(NotificationItemAdapter());
    Hive.registerAdapter(ArticleModelAdapter());
    Hive.registerAdapter(PlaylistAdapter());

    // Ouverture des boîtes
    await Future.wait([
      Hive.openBox<VideoItem>(_playlistVideos),
      Hive.openBox<VideoItem>(_feedVideos),
      Hive.openBox<FavoriteArticle>(_favorites),
      Hive.openBox<NotificationItem>(_notifications),
      Hive.openBox<ArticleModel>(_articles),
      Hive.openBox(_youtubeCache),
    ]);
  }

  // ► Méthodes utilitaires pour le cache
  // ---------------------------------------------------------------------------
  static Future<void> clearCache() async {
    await youtubeCacheBox.clear();
  }

  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }


// Utilisation dans le code :
  // Pour accéder à une boîte
final playlistVideos = HiveBoxManager.playlistVideosBox.values.toList();

// Pour ajouter un élément
await HiveBoxManager.favoritesBox.add(favoriteArticle);

// Pour vider le cache
await HiveBoxManager.clearCache();
} */