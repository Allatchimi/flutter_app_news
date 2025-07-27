import 'package:app_news/models/favorite_article.dart';
import 'package:app_news/services/favorite_service.dart';
import 'package:app_news/widgets/news_widget.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<FavoriteArticle> favorites = [];

  @override
  void initState() {
    super.initState();
    favorites = FavoriteService.getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final article = favorites[index];
          return NewsWidget(
            title: article.title,
            subtitle: '',
            publishDate: article.date,
            author: article.author,
            link: article.link,
          );
        },
      ),
    );
  }
}
