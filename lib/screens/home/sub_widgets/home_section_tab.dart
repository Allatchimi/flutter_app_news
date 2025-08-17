import 'package:app_news/screens/home/widgets/home_screen_widgets.dart';
import 'package:app_news/services/article_service.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/helper/topic_functions.dart';
import 'package:app_news/utils/onboarding_util/topic_urls.dart';
import 'package:app_news/widgets/app_text.dart';


import 'package:flutter/material.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

class HomeSectionTab extends StatefulWidget {
  final String topic;
  const HomeSectionTab({super.key, required this.topic});

  @override
  _HomeSectionTabState createState() => _HomeSectionTabState();
}

class _HomeSectionTabState extends State<HomeSectionTab> {
  RssFeed? _feed;
  bool _isLoading = false;
  String? _error;
  late final ArticleService _articleService;

  @override
  void initState() {
    super.initState();
    _articleService = ArticleService();
    _loadFeed();
  }

  @override
  void didUpdateWidget(HomeSectionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.topic != widget.topic) {
      _loadFeed();
    }
  }

  Future<void> _loadFeed() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = TopicUrls.urls[widget.topic.toUpperCase()];

      if (url == null) {
        throw Exception('No RSS URL for topic: ${widget.topic}');
      }

      final feed = await _articleService.fetchFeed(url);

      if (!mounted) return;

      setState(() {
        _feed = feed;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      debugPrint('Error loading RSS feed: $e');
    }
  }

  @override
  void dispose() {
    _articleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader1(title: convertToSpaces(widget.topic)),
        HomeSectionContent(
          error: _error,
          isLoading: _isLoading,
          feed: _feed,
          onRetry: _loadFeed,
          itemCount: 2,
        ),
        ViewMoreButton(
          topic: widget.topic,
          convertToSpaces: convertToSpaces,
          topicUrl: TopicUrls.urls[widget.topic.toUpperCase()] ?? '',
        ),
      ],
    );
  }
}
