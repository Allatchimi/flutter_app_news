import 'package:app_news/screens/view_more_screen.dart';
import 'package:app_news/services/article_service.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/helper/topic_functions.dart';
import 'package:app_news/utils/onboarding_util/topic_urls.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/news_widget.dart';
import 'package:flutter/cupertino.dart';
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
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: AppText(
                text: convertToSpaces(widget.topic),
                fontSize: 18.0,
                color: AppColors.blackColor,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Icon(
                Icons.list,
                color: AppColors.blackColor.withOpacity(0.2),
              ),
            ),
          ],
        ),
        _buildContent(),
        _buildViewMoreButton(),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _error!.contains('No internet')
                  ? Icons.wifi_off
                  : Icons.error_outline,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            if (_error!.contains('No internet'))
              ElevatedButton(
                onPressed: _loadFeed,
                child: const Text('Réessayer'),
              ),
          ],
        ),
      );
    }

    if (_feed == null || _feed!.items == null || _feed!.items!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Aucun article disponible'),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 2,
      itemBuilder: (context, index) {
        final item = _feed!.items![index];
        return NewsWidget(
          title: item.title ?? '',
          subtitle: "",
          publishDate: item.pubDate?.toString() ?? "",
          author: item.source?.url.toString() ?? "",
          link: item.link?.toString() ?? "",
        );
      },
    );
  }

  Widget _buildViewMoreButton() {
    return Row(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: InkWell(
            onTap: () {
              final url = TopicUrls.urls[widget.topic.toUpperCase()];
              if (url == null) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewMore(
                    getURL: url,
                    name: convertToSpaces(widget.topic),
                  ),
                ),
              );
            },
            child: const AppText(
              text: "View More",
              fontSize: 18.0,
              color: AppColors.blackColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
