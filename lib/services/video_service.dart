import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:app_news/models/video_item.dart';

class VideoService {
  static const String _feedUrl = "https://www.youtube.com/feeds/videos.xml?channel_id=UCuOej_TortvdHqtv7H6Kwog";
  static const Duration _cacheDuration = Duration(hours: 6);

  static Future<List<VideoItem>> fetchVideos() async {
    final box = await Hive.openBox('youtube_cache');

    final lastUpdate = box.get('lastUpdateFeedVideos') as DateTime?;
    final cachedList = box.get('feed_videos') as List?;

    // 🔄 Si cache valide (moins de 6h)
    if (lastUpdate != null &&
        cachedList != null &&
        DateTime.now().difference(lastUpdate) < _cacheDuration) {
      final videos = cachedList
          .map((json) => VideoItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      return videos;
    }

    // 🌐 Sinon, appel réseau
    try {
      final response = await http.get(Uri.parse(_feedUrl));
      if (response.statusCode != 200) {
        throw Exception("Erreur HTTP : ${response.statusCode}");
      }

      final document = xml.XmlDocument.parse(response.body);
      final entries = document.findAllElements('entry');

      final videos = entries.map((entry) {
        final title = entry.getElement('title')?.innerText ?? 'Sans titre';
        final id = entry.getElement('yt:videoId')?.innerText ?? '';
        final link = 'https://www.youtube.com/watch?v=$id';
        final description = entry.getElement('media:description')?.innerText ?? '';
        final thumbnail = entry
                .findElements('media:group')
                .expand((group) => group.findElements('media:thumbnail'))
                .firstWhere(
                  (_) => true,
                  orElse: () => xml.XmlElement(xml.XmlName('media:thumbnail')),
                )
                .getAttribute('url') ??
            '';

        return VideoItem(
          title: title,
          link: link,
          thumbnailUrl: thumbnail,
          description: description,
          id: id,
        );
      }).toList();

      // 💾 Mise en cache
      await box.put('feed_videos', videos.map((v) => v.toJson()).toList());
      await box.put('lastUpdateFeedVideos', DateTime.now());

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
}
