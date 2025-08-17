// lib/services/rss_service.dart
import 'dart:async';
import 'package:app_news/utils/handleException.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

class ArticleService {
  final http.Client _client = http.Client();
  final Duration _timeout = const Duration(seconds: 15);
  final Connectivity _connectivity = Connectivity();

  Future<RssFeed> fetchFeed(String url) async {
    // Vérifier d'abord la connexion internet
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw NetworkException('No internet connection');
    }
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);

      if (response.statusCode == 200) {
        return RssFeed.parse(response.body);
      } else {
        throw ApiException('Failed to load RSS feed: ${response.statusCode}');
      }
    } on TimeoutException {
      throw NetworkException('Request timed out');
    } on http.ClientException {
      throw NetworkException('Network error occurred');
    } catch (e) {
      throw ApiException('Failed to parse RSS feed: $e');
    }
  }
    /// Récupère le contenu HTML nettoyé d’un article
  Future<String> fetchCleanContent(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Impossible de charger l\'article');
    }

    final document = htmlParser.parse(response.body);

    // Sélectionner le contenu principal (à adapter selon le site)
    Element? content =
        document.querySelector('article') ??
        document.querySelector('.post-content') ??
        document.querySelector('#content');

    if (content == null) return '<p>Contenu indisponible</p>';

    // Supprimer toutes les publicités ou divs indésirables
    content.querySelectorAll('.ads, .banner, iframe, .sponsored').forEach((el) => el.remove());

    return content.outerHtml;
  }


  void dispose() {
    _client.close();
  }
}

