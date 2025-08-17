import 'package:app_news/screens/common/view_more_screen.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/app_constants.dart';
import 'package:app_news/utils/helper/data_functions.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/screens/article/widgets/news_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';

class HomeSectionCountry extends StatefulWidget {
  const HomeSectionCountry({super.key});

  @override
  _HomeSectionCountryState createState() => _HomeSectionCountryState();
}

class _HomeSectionCountryState extends State<HomeSectionCountry> {
  final DataHandler _dataHandler = DataHandler();
  final http.Client _httpClient = http.Client();
  
  RssFeed? _feed;
  bool _isLoading = true;
  String? _error;
  
  String _country = "";
  String _countryCode = "";
  String _lang = "";
  String _langCode = "";

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final country = await _dataHandler.getStringValue(AppConstants.countryName);
      final countryCode = await _dataHandler.getStringValue(AppConstants.countryCode);
      final lang = await _dataHandler.getStringValue(AppConstants.langName);
      final langCode = await _dataHandler.getStringValue(AppConstants.langCode);

      if (!mounted) return;
      
      setState(() {
        _country = country;
        _countryCode = countryCode;
        _lang = lang;
        _langCode = langCode;
      });

      await _loadFeed();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFeed() async {
    try {
      setState(() => _isLoading = true);
      
      final url = "https://news.google.com/rss?ceid=${_countryCode}:${_langCode}&hl=${_lang.toLowerCase()}&gl=${_countryCode}";
      
      final response = await _httpClient
          .get(Uri.parse(url))
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
      debugPrint('Error loading country feed: $e');
    }
  }

  @override
  void dispose() {
    _httpClient.close();
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
                text: "C o u n t r y",
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
                    getURL: "https://news.google.com/rss?ceid=${_countryCode}:${_langCode}&hl=${_langCode.toLowerCase()}&gl=${_countryCode}",
                    name: "C o u n t r y",
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