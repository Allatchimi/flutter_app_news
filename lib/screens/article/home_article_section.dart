import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_news/services/article_service.dart';
import 'package:app_news/screens/article/widgets/news_widget.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/screens/common/view_more_screen.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

class HomeArticleSection extends StatefulWidget {
  final String sectionTitle;
  final String rssUrl;
  final String viewMoreLabel;

  const HomeArticleSection({
    super.key,
    required this.sectionTitle,
    required this.rssUrl,
    required this.viewMoreLabel,
  });

  @override
  State<HomeArticleSection> createState() => _HomeArticleSectionState();
}

class _HomeArticleSectionState extends State<HomeArticleSection> {
  final ArticleService _articleService = ArticleService();

  RssFeed? _feed;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final feed = await _articleService.fetchFeed(widget.rssUrl);
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
            text: widget.sectionTitle,
            fontSize: 18.0,
            color: AppColors.blackColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(Icons.list, color: AppColors.blackColor.withOpacity(0.2)),
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
      itemCount: 2,
      itemBuilder: (context, index) {
        final item = _feed!.items![index];
        return NewsWidget(
          title: item.title ?? '',
          subtitle: '',
          publishDate: item.pubDate?.toString() ?? '',
          author: item.source?.url.toString() ?? '',
          link: item.link ?? '',
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
                  builder: (_) => ViewMore(
                    getURL: widget.rssUrl,
                    name: widget.viewMoreLabel,
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
        )
      ],
    );
  }
}
