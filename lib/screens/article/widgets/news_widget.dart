// ✅ NEWSWIDGET ADAPTÉ POUR FavoriteArticle + FavoritesPage utilisant Hive

import 'package:app_news/services/favorite_service.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/helper/author_function.dart';
import 'package:app_news/utils/helper/date_functions.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/news_webview.dart';
import 'package:flutter/material.dart';
import 'package:app_news/models/favorite_article.dart';

class NewsWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String publishDate;
  final String author;
  final String link;

  const NewsWidget({super.key,
    required this.title,
    required this.subtitle,
    required this.publishDate,
    required this.author,
    required this.link,
  });

  @override
  State<NewsWidget> createState() => _NewsWidgetState();
}

class _NewsWidgetState extends State<NewsWidget> {
  bool isFavorite = false;

  void _checkFavorite() {
    final result = FavoriteService.isFavorite(widget.link);
    setState(() {
      isFavorite = result;
    });
  }

  void _toggleFavorite() {
    final article = FavoriteArticle(
      title: widget.title,
      link: widget.link,
      author: widget.author,
      date: widget.publishDate,
    );
    if (isFavorite) {
      FavoriteService.removeFromFavorites(article.link);
    } else {
      FavoriteService.addToFavorites(article);
    }
    _checkFavorite();
  }

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: widget.title,
                  fontSize: 16.0,
                  color: Colors.black,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          text: convertToRegularDateFormat(widget.publishDate),
                          fontSize: 12.0,
                          color: AppColors.blackColor.withOpacity(0.5),
                          fontWeight: FontWeight.normal,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            AppText(
                              text: 'By ',
                              fontSize: 12.0,
                              color: AppColors.blackColor.withOpacity(0.5),
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.ellipsis,
                            ),
                            AppText(
                              text: extractDomainName(widget.link),
                              fontSize: 12.0,
                              color: AppColors.blackColor.withOpacity(1),
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite ? Colors.amber : Colors.grey,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsWebviewApp(newsURL: widget.link),
                            ),
                          );
                        },
                        child: const AppText(
                          text: "V I S I T",
                          fontSize: 12.0,
                          color: Colors.black,
                          maxLines: 4,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
