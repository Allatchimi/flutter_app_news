import 'dart:async';
import 'dart:math';
import 'package:app_news/utils/handleException.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';


class HomeService {
  final http.Client _client = http.Client();
  final Duration _timeout;
  final Connectivity _connectivity;
  Completer<void>? _disposeCompleter;
  final _cache = <String, RssFeed>{};

  HomeService({
    Duration? timeout,
    Connectivity? connectivity,
  }) : _timeout = timeout ?? const Duration(seconds: 15),
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
        if (attempt >= retries || (e.statusCode != null && e.statusCode! >= 500)) {
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

  Future<void> _exponentialBackoff(int attempt) async {
    final delay = Duration(seconds: min(pow(2, attempt).toInt(), 30)); // Max 30s
    await Future.delayed(delay);
  }

  Future<RssFeed> fetchFeed(String url) async {
    if (_cache.containsKey(url)) return _cache[url]!;
    if (_disposeCompleter != null) throw StateError('Service disposed');

    try {
      await _checkConnectivity();
      final response = await _makeHttpRequest(url);
      return _parseResponse(url, response);
    } on http.ClientException {
      throw NetworkException('Erreur réseau');
    } catch (e) {
      throw ApiException('Erreur de traitement: ${e.toString()}');
    }
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (result == ConnectivityResult.none) {
      throw NetworkException('Pas de connexion internet');
    }
  }

  Future<http.Response> _makeHttpRequest(String url) async {
    return await _client.get(Uri.parse(url))
        .timeout(_timeout, onTimeout: () {
          _client.close();
          throw TimeoutException('Request timed out');
        });
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
    _disposeCompleter!.complete();
  }
}