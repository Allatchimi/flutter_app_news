import 'dart:async';
import 'dart:math';
import 'package:app_news/utils/handleException.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as htmlParser;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';
import 'package:flutter/foundation.dart';

class ArticleService {
  final http.Client _client = http.Client();
  final Duration _timeout;
  final Connectivity _connectivity;
  Completer<void>? _disposeCompleter;
  final _cache = <String, RssFeed>{};
  final _cleanContentCache = <String, String>{};

  ArticleService({Duration? timeout, Connectivity? connectivity})
    : _timeout = timeout ?? const Duration(seconds: 15),
      _connectivity = connectivity ?? Connectivity();

  Future<RssFeed> fetchFeedWithRetry(String url, {int retries = 3}) async {
    int attempt = 0;
    late RssFeed feed;

    while (attempt < retries) {
      attempt++;
      try {
        feed = await fetchFeed(url);
        return feed;
      } on NetworkException catch (e) {
        if (attempt >= retries) throw e;
        await _exponentialBackoff(attempt);
      } on ApiException catch (e) {
        if (attempt >= retries ||
            (e.statusCode != null && e.statusCode! >= 500)) {
          throw e;
        }
        await Future.delayed(const Duration(seconds: 1));
      } on TimeoutException {
        if (attempt >= retries) rethrow;
        await _exponentialBackoff(attempt);
      }
    }
    throw ApiException('Échec après $retries tentatives');
  }

  Future<RssFeed> fetchFeed(String url) async {
    if (_cache.containsKey(url)) return _cache[url]!;
    if (_disposeCompleter != null) throw StateError('Service disposed');

    try {
      await _checkConnectivity();
      final response = await _makeHttpRequest(url);
      final feed = _parseResponse(url, response);

      await _enrichFeedItems(feed);

      return feed;
    } on http.ClientException {
      throw NetworkException('Erreur réseau');
    } catch (e) {
      throw ApiException('Erreur de traitement: ${e.toString()}');
    }
  }

  Future<void> _enrichFeedItems(RssFeed feed) async {
    if (feed.items == null) return;

    for (final item in feed.items!) {
      if (item.link != null && !_cleanContentCache.containsKey(item.link)) {
        try {
          final cleanContent = await fetchCleanContent(item.link!);
          _cleanContentCache[item.link!] = cleanContent;
        } catch (e) {
          debugPrint('Erreur lors du nettoyage de ${item.link}: $e');
          _cleanContentCache[item.link!] = '<p>Contenu non disponible</p>';
        }
      }
    }
  }

  // Méthode publique pour accéder au contenu nettoyé
  String? getCleanContent(String url) {
    return _cleanContentCache[url];
  }

  Future<String> fetchCleanContent(String url) async {
    final response = await _client.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception(
        'Impossible de charger l\'article: ${response.statusCode}',
      );
    }

    final document = htmlParser.parse(response.body);

    final selectors = [
      'article',
      '.post-content',
      '.article-content',
      '#content',
      '.main-content',
      '.entry-content',
      '.story-content',
      '[role="main"]',
      'main',
    ];

    dom.Element? content;
    for (final selector in selectors) {
      content = document.querySelector(selector);
      if (content != null) break;
    }

    if (content == null) {
      final divs = document.querySelectorAll('div');
      content = divs.fold<dom.Element?>(null, (largest, current) {
        final textLength = current.text.length;
        if (largest == null || textLength > largest.text.length) {
          return current;
        }
        return largest;
      });
    }

    if (content == null) return '<p>Contenu indisponible</p>';

    final unwantedSelectors = [
      '.ads',
      '.banner',
      '.advertisement',
      '.sponsored',
      '.social-share',
      '.comments',
      '.related-posts',
      'iframe',
      'script',
      'nav',
      'footer',
      'header',
    ];

    for (final selector in unwantedSelectors) {
      content.querySelectorAll(selector).forEach((el) => el.remove());
    }

    return content.outerHtml;
  }

  Future<void> _exponentialBackoff(int attempt) async {
    final delay = Duration(seconds: min(pow(2, attempt).toInt(), 30));
    await Future.delayed(delay);
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      throw NetworkException('Pas de connexion internet');
    }
  }

  Future<http.Response> _makeHttpRequest(String url) async {
    final headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept': 'application/rss+xml, application/xml, text/xml, */*',
      'Accept-Language': 'fr-FR,fr;q=0.9,en-US;q=0.8,en;q=0.7',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
    };

    final response = await _client
        .get(Uri.parse(url), headers: headers)
        .timeout(
          _timeout,
          onTimeout: () {
            throw TimeoutException('Request timed out');
          },
        );

    // DEBUG: Afficher les entêtes et le début du contenu
    debugPrint('URL: $url');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Content-Type: ${response.headers['content-type']}');
    debugPrint(
      'First 200 chars: ${response.body.substring(0, min(200, response.body.length))}',
    );

    return response;
  }

  RssFeed _parseResponse(String url, http.Response response) {
    if (response.statusCode != 200) {
      throw ApiException('Erreur serveur', response.statusCode);
    }

    try {
      final feed = RssFeed.parse(response.body);

      _cache[url] = feed;
      return feed;
    } catch (e) {
      throw ApiException('Erreur de parsing RSS: ${e.toString()}');
    }
  }

  Future<void> dispose() async {
    if (_disposeCompleter != null) return;

    _disposeCompleter = Completer<void>();
    _client.close();
    _cache.clear();
    _cleanContentCache.clear();
    _disposeCompleter!.complete();
  }
}
