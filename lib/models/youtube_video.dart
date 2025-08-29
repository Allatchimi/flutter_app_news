class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String url;
  final Map<String, String> thumbnails;
  final String publishedAt;
  final String duration;
  final String channelId;
  
  YouTubeVideo({
    required this.id,
    required this.title,
    required this.description,
    required this.url,
    required this.thumbnails,
    required this.publishedAt,
    required this.duration,
    required this.channelId,
  });

    // Méthode utilitaire pour obtenir la meilleure thumbnail
  String get bestThumbnail {
    return thumbnails['high'] ?? 
           thumbnails['medium'] ?? 
           thumbnails['default'] ?? 
           '';
  }

}