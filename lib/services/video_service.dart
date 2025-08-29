import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:app_news/models/video_item.dart';

enum FeedType { youtube, genericRss, atom, alwihda, dailymotion }

class VideoService {
  static const Duration _cacheDuration = Duration(hours: 6);

  static Future<List<VideoItem>> fetchVideos(String feedUrl) async {

    final box = await Hive.openBox('video_cache');
    final cacheKey = 'videos_${feedUrl.hashCode}';
    final lastUpdateKey = 'lastUpdate_${feedUrl.hashCode}';

    final lastUpdate = box.get(lastUpdateKey) as DateTime?;
    final cachedList = box.get(cacheKey) as List?;

    if (lastUpdate != null &&
        cachedList != null &&
        DateTime.now().difference(lastUpdate) < _cacheDuration) {
      return cachedList
          .map((json) => VideoItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    }

    try {
      final response = await http.get(Uri.parse(feedUrl));
      if (response.statusCode != 200) {
        throw Exception("Erreur HTTP : ${response.statusCode}");
      }

      final document = xml.XmlDocument.parse(response.body);
      final List<VideoItem> videos;

      if (_isYouTubeFeed(document)) {
        videos = _parseYouTubeFeed(document);
      } else if (_isAtomFeed(document)) {
        videos = _parseAtomFeed(document);
      } else if (_isAlwihdaFeed(document)) {
        videos = _parseAlwihdaFeed(document);
      } else {
        videos = _parseGenericRss(document);
      }

      await box.put(cacheKey, videos.map((v) => v.toJson()).toList());
      await box.put(lastUpdateKey, DateTime.now());

      return videos;
    } catch (e) {
      if (cachedList != null) {
        return cachedList
            .map((json) => VideoItem.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      rethrow;
    }
  }

  static bool _isYouTubeFeed(xml.XmlDocument doc) {
    return doc.findAllElements('yt:videoId').isNotEmpty ||doc.findAllElements('yt:channelId').isNotEmpty ||
           doc.toString().contains('youtube.com');
  }

  static bool _isAtomFeed(xml.XmlDocument doc) {
    return doc.findAllElements('feed').isNotEmpty &&
           doc.findElements('feed').first.getAttribute('xmlns')?.contains('atom') == true;
  }

  static bool _isAlwihdaFeed(xml.XmlDocument doc) {
    return doc.findAllElements('item').any((item) {
      final link = item.getElement('link')?.innerText ?? '';
      return link.contains('alwihda');
    });
  }

  static List<VideoItem> _parseYouTubeFeed(xml.XmlDocument document) {
    return document.findAllElements('entry').map((entry) {
      final title = entry.getElement('title')?.innerText ?? 'Sans titre';
      final id = entry.getElement('yt:videoId')?.innerText ?? '';
      final link = 'https://www.youtube.com/watch?v=$id';
      final description = entry.getElement('media:description')?.innerText ?? '';
      
      final thumbnail = entry
          .findElements('media:group')
          .expand((group) => group.findElements('media:thumbnail'))
          .firstWhere(
            (thumb) => true,
            orElse: () => xml.XmlElement(xml.XmlName('media:thumbnail')),
          )
          .getAttribute('url') ?? '';

      return VideoItem(
        title: title,
        link: link,
        thumbnailUrl: thumbnail,
        description: description,
        id: id,
        source: 'YouTube',
      );
    }).toList();
  }

  static List<VideoItem> _parseAtomFeed(xml.XmlDocument document) {
    return document.findAllElements('entry').map((entry) {
      final title = entry.getElement('title')?.innerText ?? 'Sans titre';
      final link = entry.getElement('link')?.getAttribute('href') ?? 
                  entry.getElement('link')?.innerText ?? '';
      final description = entry.getElement('summary')?.innerText ?? '';
      
      final thumbnail = entry
          .findElements('media:thumbnail')
          .firstOrNull
          ?.getAttribute('url') ?? '';

      return VideoItem(
        title: title,
        link: link,
        thumbnailUrl: _validateThumbnailUrl(thumbnail),
        description: description,
        id: _extractVideoId(link),
        source: 'Atom Feed',
      );
    }).toList();
  }

static List<VideoItem> _parseAlwihdaFeed(xml.XmlDocument document) {
  return document.findAllElements('item').map((item) {
    final title = item.getElement('title')?.innerText ?? 'Sans titre';
    final link = item.getElement('link')?.innerText ?? '';
    final description = item.getElement('description')?.innerText ?? '';
    
    // URL DE LA VIDÉO (pour la lecture)
    final videoUrl = item.getElement('enclosure')?.getAttribute('url') ?? '';
    
    // URL DE L'IMAGE (pour le thumbnail) - CORRECTION ICI
    final thumbnail = item.findElements('photo:imgsrc').firstOrNull?.innerText ?? 
                     _extractImageFromDescription(description);

    return VideoItem(
      title: title,
      link: videoUrl.isNotEmpty ? videoUrl : link, // Utiliser l'URL vidéo si disponible
      thumbnailUrl: _validateThumbnailUrl(thumbnail),
      description: description,
      id: _extractVideoId(videoUrl.isNotEmpty ? videoUrl : link),
      source: 'Alwihda Info',
    );
  }).toList();
}
  // NOUVELLE MÉTHODE : Extraction spécifique pour Alwihda
  static String _extractAlwihdaThumbnail(xml.XmlElement item) {
    // 1. Essayer photo:imgsrc (avec namespace correct)
    final photoImgsrc = item.findElements('photo:imgsrc').firstOrNull?.innerText;
    if (photoImgsrc != null && photoImgsrc.isNotEmpty) {
      return _validateThumbnailUrl(photoImgsrc);
    }

    // 2. Essayer media:thumbnail
    final mediaThumbnail = item
        .findElements('media:thumbnail')
        .firstOrNull
        ?.getAttribute('url');
    if (mediaThumbnail != null && mediaThumbnail.isNotEmpty) {
      return _validateThumbnailUrl(mediaThumbnail);
    }

    // 3. Essayer enclosure (mais vérifier que c'est une image)
    final enclosure = item.getElement('enclosure');
    final enclosureUrl = enclosure?.getAttribute('url');
    if (enclosureUrl != null && enclosureUrl.isNotEmpty) {
      final type = enclosure?.getAttribute('type') ?? '';
      if (type.startsWith('image/')) {
        return _validateThumbnailUrl(enclosureUrl);
      }
    }

    // 4. Extraire de la description HTML
    final description = item.getElement('description')?.innerText ?? '';
    final extractedFromDescription = _extractImageFromDescription(description);
    if (extractedFromDescription.isNotEmpty) {
      return _validateThumbnailUrl(extractedFromDescription);
    }

    // 5. Fallback : image par défaut ou vide
    return '';
  }

  static List<VideoItem> _parseGenericRss(xml.XmlDocument document) {
    return document.findAllElements('item').map((item) {
      final title = item.getElement('title')?.innerText ?? 'Sans titre';
      final link = item.getElement('link')?.innerText ?? '';
      final description = item.getElement('description')?.innerText ?? '';
      
      final thumbnail = item.getElement('media:thumbnail')?.getAttribute('url') ??
                       item.getElement('enclosure')?.getAttribute('url') ??
                       _extractImageFromDescription(description);

      return VideoItem(
        title: title,
        link: link,
        thumbnailUrl: _validateThumbnailUrl(thumbnail),
        description: description,
        id: _extractVideoId(link),
        source: 'RSS',
      );
    }).toList();
  }

  // VALIDATION des URLs de thumbnails
  static String _validateThumbnailUrl(String url) {
    if (url.isEmpty) return '';
    
    // Liste des extensions vidéo à éviter
    final videoExtensions = ['.mp4', '.mov', '.avi', '.webm', '.m4v', '.wmv'];
    final lowerUrl = url.toLowerCase();
    
    for (final ext in videoExtensions) {
      if (lowerUrl.endsWith(ext)) {
        return ''; // URL de vidéo détectée, retourner vide
      }
    }
    
    return url;
  }

  static String _extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    
    if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return uri.queryParameters['v'] ?? 
             uri.pathSegments.lastWhere((seg) => seg.isNotEmpty, orElse: () => '');
    }
    
    if (url.contains('dailymotion.com')) {
      return uri.pathSegments.lastWhere((seg) => seg.isNotEmpty, orElse: () => '');
    }
    
    return '';
  }

  static String _extractImageFromDescription(String html) {
    final regex = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = regex.firstMatch(html);
    final extractedUrl = match?.group(1) ?? '';
    return _validateThumbnailUrl(extractedUrl);
  }

  // Helper pour firstOrNull
  static T? firstOrNull<T>(Iterable<T> items) {
    try {
      return items.first;
    } catch (e) {
      return null;
    }
  }
}