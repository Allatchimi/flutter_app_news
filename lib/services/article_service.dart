// lib/services/rss_service.dart
import 'dart:async';
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

  void dispose() {
    _client.close();
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}