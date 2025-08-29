import 'package:app_news/screens/article/widgets/article_widgets.dart';
import 'package:app_news/services/article_service.dart';
import 'package:app_news/utils/helper/topic_functions.dart';
import 'package:app_news/utils/onboarding_util/topic_urls.dart';
import 'package:flutter/material.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

class SectionTab extends StatefulWidget {
  final String topic;
  const SectionTab({super.key, required this.topic});

  @override
  _SectionTabState createState() => _SectionTabState();
}

class _SectionTabState extends State<SectionTab> {
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
  void didUpdateWidget(SectionTab oldWidget) {
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
      
      for (var item in feed.items!) {
        if (item.link != null) {
          final cleanContent = _articleService.getCleanContent(item.link!);
          //print('Article: ${item.title}');
         // print('Contenu nettoyé: $cleanContent');
        }
      }

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
