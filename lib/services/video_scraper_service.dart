import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart';

class ScrapedVideo {
  final String videoId;
  final String videoUrl;
  final String thumbnailUrl;

  ScrapedVideo({
    required this.videoId,
    required this.videoUrl,
    required this.thumbnailUrl,
  });
}

class VideoScraperService {
  /// Récupère les vidéos YouTube intégrées à une seule page
  static Future<List<ScrapedVideo>> scrapeYoutubeVideosFromPage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception("Erreur chargement HTML");

    final document = parse(response.body);
    final videos = <ScrapedVideo>[];

    // Recherche des balises iframe YouTube
    final iframes = document.getElementsByTagName('iframe');
    for (Element iframe in iframes) {
      final src = iframe.attributes['src'];
      if (src != null && src.contains('youtube.com/embed/')) {
        final videoId = src.split('/embed/').last.split('?').first;
        videos.add(_buildScrapedVideo(videoId));
      }
    }

    // Recherche des liens vers YouTube
    final links = document.querySelectorAll('a[href]');
    for (Element link in links) {
      final href = link.attributes['href'];
      if (href != null && href.contains('youtube.com/watch?v=')) {
        final videoId = Uri.parse(href).queryParameters['v'] ?? href.split('v=').last;
        videos.add(_buildScrapedVideo(videoId));
      }
    }

    return videos;
  }


  /// Crée un objet ScrapedVideo
  static ScrapedVideo _buildScrapedVideo(String videoId) {
    return ScrapedVideo(
      videoId: videoId,
      videoUrl: "https://www.youtube.com/watch?v=$videoId",
      thumbnailUrl: "https://img.youtube.com/vi/$videoId/0.jpg",
    );
  }
}
