
import 'package:app_news/screens/view_more_screen.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/news_widget.dart';
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
  final String rssUrl = "https://news.google.com/rss/headlines/section/geo/US?ceid=US:EN&hl=en&gl=US";
  RssFeed? _feed;
  bool _isLoading = true;
  String? _error;
  http.Client? _httpClient;

  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    try {
      final response = await _httpClient!
          .get(Uri.parse(rssUrl))
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _feed = RssFeed.parse(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error loading geo feed: $e');
    }
  }

  @override
  void dispose() {
    _httpClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.all(15.0),
              child: AppText(
                text: "G e o l o g i c a l",
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
            )
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
        child: Text('Error: $_error', style: TextStyle(color: Colors.red)),
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
                    getURL: rssUrl,
                    name: "G e o l o g i c a l",
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