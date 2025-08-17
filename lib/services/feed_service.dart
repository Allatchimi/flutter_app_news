import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:html/dom.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

class FeedService {
  /// Récupère le flux RSS
  Future<RssFeed> fetchFeed(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Impossible de charger le feed');
    return RssFeed.parse(response.body);
  }

  /// Récupère le contenu d’un article (net, sans pubs)
  Future<String> fetchCleanArticle(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('Impossible de charger l\'article');

    final document = htmlParser.parse(response.body);

    // Sélecteur spécifique pour Manara.td
    Element? content = document.querySelector('.td-post-content');

    // Supprime les pubs ou iframes indésirables
    content?.querySelectorAll('iframe, .ads, .banner, .sponsored').forEach((el) => el.remove());

    return content?.outerHtml ?? '<p>Contenu indisponible</p>';
  }

}
