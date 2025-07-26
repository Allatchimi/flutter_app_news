import 'package:app_news/screens/view_more_screen.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/helper/topic_functions.dart';
import 'package:app_news/utils/onboarding_util/topic_urls.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/news_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';

class HomeSectionTab extends StatefulWidget {
  final String topic;
  const HomeSectionTab({super.key, required this.topic});

  @override
  _HomeSectionTabState createState() => _HomeSectionTabState();
}

class _HomeSectionTabState extends State<HomeSectionTab> {
  RssFeed? feed;
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final List<RssItem> _displayedItems = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    loadFeed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent && 
        !isLoadingMore && 
        hasMore) {
      loadMore();
    }
  }

  Future<void> loadFeed() async {
    try {
      final url = TopicUrls.urls[widget.topic.toUpperCase()];
      if (url == null) return;

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final parsedFeed = RssFeed.parse(response.body);
        setState(() {
          feed = parsedFeed;
          _displayedItems.addAll(parsedFeed.items?.take(2) ?? []);
        });
      }
    } catch (e) {
      print("Erreur RSS: $e");
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || !hasMore) return;
    
    setState(() => isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1)); // Simule le chargement
    
    try {
      if (feed?.items != null) {
        final newItems = feed!.items!.skip(_displayedItems.length).take(2).toList();
        
        if (newItems.isEmpty) {
          setState(() => hasMore = false);
        } else {
          setState(() => _displayedItems.addAll(newItems));
        }
      }
    } catch (e) {
      print("Erreur chargement supplémentaire: $e");
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  String? _extractImageUrl(String? html) {
    if (html == null) return null;
    final regex = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = regex.firstMatch(html);
    return match?.group(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
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

        // Liste des articles
        SizedBox(
          child: _displayedItems.isEmpty
              ? const Center(child: CupertinoActivityIndicator())
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && 
                        !isLoadingMore && 
                        hasMore) {
                      loadMore();
                    }
                    return false;
                  },
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: _displayedItems.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _displayedItems.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CupertinoActivityIndicator()),
                        );
                      }

                      final item = _displayedItems[index];
                      final imageUrl = _extractImageUrl(item.description);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (imageUrl != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 80,
                                      height: 80,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ),
                            Expanded(
                              child: NewsWidget(
                                title: item.title ?? '',
                                subtitle: item.description ?? '',
                                publishDate: item.pubDate?.toString() ?? '',
                                author: item.source?.url.toString() ?? '',
                                link: item.link ?? '',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),

        // View More button
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final url = TopicUrls.urls[widget.topic.toUpperCase()];
                if (url != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewMore(
                        getURL: url,
                        name: convertToSpaces(widget.topic),
                      ),
                    ),
                  );
                }
              },
              child: const AppText(
                text: "View More →",
                fontSize: 16.0,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}