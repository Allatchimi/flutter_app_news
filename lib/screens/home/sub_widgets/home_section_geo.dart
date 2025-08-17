import 'dart:io';

import 'package:app_news/screens/home/widgets/home_screen_widgets.dart';
import 'package:app_news/services/home_service.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/helper/topic_functions.dart';
import 'package:app_news/utils/onboarding_util/topic_urls.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';

class HomeSectionGeo extends StatefulWidget {
  const HomeSectionGeo({super.key});

  @override
  _HomeSectionGeoState createState() => _HomeSectionGeoState();
}

class _HomeSectionGeoState extends State<HomeSectionGeo> {
  final HomeService _homeService = HomeService();
  //final rssUrl = "https://manara.td/feed/";
  final rssUrl = TopicUrls.urls['TCHADONE'] ?? '';
  RssFeed? _feed;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (!mounted) return; // Protection initiale

    setState(() => _isLoading = true);

    try {
      final feed = await _homeService.fetchFeed(rssUrl);

      if (!mounted) return; // Vérification après l'opération asynchrone

      setState(() {
        _feed = feed;
        _isLoading = false;
        _error = null; // Réinitialiser les erreurs précédentes
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e is SocketException
            ? 'Problème de connexion internet'
            : e.toString();
        _isLoading = false;
      });

      debugPrint('Erreur de chargement RSS: $e');
    }
  }

  @override
  void dispose() {
    _homeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader1(title: "T C H A D ONE NEWS"),
        HomeSectionContent(
          isLoading: _isLoading,
          error: _error,
          feed: _feed,
          onRetry: _loadFeed,
          itemCount: 2,
        ),
        ViewMoreButton(
          topicUrl: rssUrl,
          convertToSpaces: convertToSpaces,
          topic: "T C H A D ONE NEWS",
        ),
      ],
    );
  }
}
