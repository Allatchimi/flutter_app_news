import 'package:app_news/screens/home/widgets/home_screen_widgets.dart';
import 'package:app_news/services/home_service.dart';
import 'package:app_news/utils/handleException.dart';
import 'package:app_news/utils/helper/topic_functions.dart';
import 'package:flutter/material.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

class HomeSectionCountry extends StatefulWidget {
  const HomeSectionCountry({super.key});

  @override
  _HomeSectionCountryState createState() => _HomeSectionCountryState();
}

class _HomeSectionCountryState extends State<HomeSectionCountry> {
  final HomeService _homeService = HomeService();
  final String url = "https://www.alwihdainfo.com/xml/syndication.rss";
  
  RssFeed? _feed;
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (_isDisposed) return;

    setState(() => _isLoading = true);

    try {
      final feed = await _homeService.fetchFeed(url);
      
      if (_isDisposed || !mounted) return;
      
      setState(() {
        _feed = feed;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (_isDisposed || !mounted) return;
      
      setState(() {
        _error = e is NetworkException 
               ? e.toString()
               : 'Erreur de chargement des articles';
        _isLoading = false;
      });
      
      debugPrint('Erreur de chargement RSS: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _homeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SectionHeader1(title: "A L W I H I D A  NEWS"),
        HomeSectionContent(
          isLoading: _isLoading,
          error: _error,
          feed: _feed,
          onRetry: _loadFeed,
          itemCount: 2,
        ),
        ViewMoreButton(
          topicUrl: url,
          convertToSpaces: convertToSpaces,
          topic: "A L W I H I D A  NEWS",
        ),
      ],
    );
  }
}