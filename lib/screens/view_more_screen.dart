import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/widgets/generic_app_bar.dart';
import 'package:app_news/widgets/news_widget.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';
import 'package:flutter/material.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

class ViewMore extends StatefulWidget {

  final String name;
  final String getURL;
  const ViewMore({super.key, required this.getURL, required this.name});

  @override
  _ViewMoreState createState() => _ViewMoreState();
}

class _ViewMoreState extends State<ViewMore> {
  RssFeed? feed;
  
  get _shareArticle => null;

  @override
  void initState() {
    super.initState();
    loadFeed();
  }

Future<void> loadFeed() async {
  try {
    final response = await http.get(Uri.parse(widget.getURL));


    if (response.statusCode == 200) {
      final body = response.body.trim();
      if (body.startsWith('<?xml')) {
        setState(() {
          feed = RssFeed.parse(body);
        });
      } else {
        throw Exception("🚨 Contenu inattendu (pas un flux XML)");
      }
    } else {
      throw Exception("🚨 HTTP ${response.statusCode}");
    }
  } catch (e, s) {
    print("❌ Erreur lors du chargement RSS: $e");
    print("Stack: $s");
  }
}


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
  appBar: GenericAppBar(
    title: widget.name,
    iconColor: AppColors.blackColor,
    backgroundColor: AppColors.primaryColor,
    onBackPressed: () {
      // Action personnalisée avant retour
      _confirmExit(context);
    },
    actions: [
      IconButton(
        icon: const Icon(Icons.share),
        onPressed: _shareArticle,
      ),
      IconButton(
        icon: const Icon(Icons.bookmark_border),
        onPressed: _saveArticle,
      ),
    ],
  ),
      body: SizedBox(
        child: feed == null
            ? const Center(
          child: CupertinoActivityIndicator(),
        )
            : ListView.builder(
          // shrinkWrap: true,
          itemCount: feed!.items?.length ?? 0,
          // itemCount: 2,
          itemBuilder: (context, index) {
            var item = feed!.items?[index];
            return NewsWidget(
                title: item?.title ?? '',
                subtitle: "",
                publishDate: item?.pubDate?.toString() ?? "",
                author: item?.source?.url.toString() ??  'Auteur inconnu',
                link: item?.link?.toString() ?? "");
          },
        ),
      ),
    );
  }
  
  void _confirmExit(BuildContext context) {
    Navigator.of(context).pop();
  }

  void _saveArticle() {
  }
}