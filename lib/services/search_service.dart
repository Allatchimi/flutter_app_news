import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:app_news/models/article_model.dart';

class SearchService {
  final http.Client _client = http.Client();

  Future<List<ArticleModel>> searchInRssFeed(String query, String rssUrl) async {
    try {
      final response = await _client.get(Uri.parse(rssUrl)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        return _filterArticles(feed, query);
      } else {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  List<ArticleModel> _filterArticles(RssFeed feed, String query) {
    if (feed.items == null || feed.items!.isEmpty) return [];

    return feed.items!
        .where((item) =>
            (item.title?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (item.description?.toLowerCase().contains(query.toLowerCase()) ?? false))
        .map((item) => ArticleModel(
              title: item.title ?? 'No title',
              link: item.link ?? '',
              author: item.dc?.creator ?? item.source?.url ?? 'Unknown',
              publishDate: item.pubDate ?? DateTime.now(),
              description: item.description ?? '',
            ))
        .toList();
  }

  void dispose() {
    _client.close();
  }
}