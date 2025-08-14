// lib/widgets/rss_section_widget.dart
import 'package:app_news/screens/view_more_screen.dart';
import 'package:app_news/services/article_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webfeed_plus/webfeed_plus.dart';
import 'app_text.dart';
import 'news_widget.dart';

class RssSectionWidget extends StatefulWidget {
  final String title;
  final String rssUrl;
  final int itemsToShow;

  const RssSectionWidget({
    super.key,
    required this.title,
    required this.rssUrl,
    this.itemsToShow = 2,
  });

  @override
  _RssSectionWidgetState createState() => _RssSectionWidgetState();
}

class _RssSectionWidgetState extends State<RssSectionWidget> {
  final ArticleService _rssService = ArticleService();
  RssFeed? _feed;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }
  @override
  void didUpdateWidget(RssSectionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rssUrl != widget.rssUrl) {
      _loadFeed();
    }
  }

  Future<void> _loadFeed() async {
    try {
      final feed = await _rssService.fetchFeed(widget.rssUrl);
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
      debugPrint('Error loading ${widget.title} feed: $e');
    }
  }



  @override
  void dispose() {
    _rssService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildContent(),
        _buildViewMoreButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: AppText(
            text: widget.title,
            fontSize: 18.0,
            color: Colors.black,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.all(15.0),
          child: Icon(
            Icons.list,
            color: Colors.black12,
          ),
        ),
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
        child: Text('Error: $_error', style: const TextStyle(color: Colors.red)),
      );
    }
    
    if (_feed == null || _feed!.items == null || _feed!.items!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No articles available'),
      );
    }
    
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.itemsToShow,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewMore(
                    getURL: widget.rssUrl,
                    name: widget.title,
                  ),
                ),
              );
            },
            child: const AppText(
              text: "View More",
              fontSize: 18.0,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}