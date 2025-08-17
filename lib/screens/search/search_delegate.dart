import 'package:app_news/screens/article/widgets/news_widget.dart';
import 'package:flutter/material.dart';
import 'package:app_news/models/article_model.dart';
import 'package:app_news/services/search_service.dart';
import 'package:app_news/utils/onboarding_util/topic_urls.dart';

class NewsSearchDelegate extends SearchDelegate<ArticleModel?> {
  final SearchService searchService;

  NewsSearchDelegate(this.searchService);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<ArticleModel>>(
      future: _performSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final results = snapshot.data ?? [];
        
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final article = results[index];
            return NewsWidget(
                title: article.title,
                subtitle: "",
                publishDate: article.publishDate.toString(),
                author: article.author.toString(),
                link: article.link.toString());
          },
        );
      },
    );
  }

  Future<List<ArticleModel>> _performSearch(String query) async {
    if (query.isEmpty) return [];
    
    final results = <ArticleModel>[];
    
    // Recherche dans tous les flux RSS disponibles
    for (final url in TopicUrls.urls.values) {
      try {
        final articles = await searchService.searchInRssFeed(query, url);
        results.addAll(articles);
      } catch (e) {
        debugPrint('Error searching in $url: $e');
      }
    }
    
    return results;
  }

@override
Widget buildSuggestions(BuildContext context) {
  return FutureBuilder<List<ArticleModel>>(
    future: _performSearch(query),
    builder: (context, snapshot) {
      if (query.isEmpty) {
        return const Center(
          child: Text('Entrez un terme pour rechercher dans les actualités'),
        );
      }
      
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      
      final suggestions = snapshot.data ?? [];
      
      return ListView.builder(
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final article = suggestions[index];
          return ListTile(
            title: Text(article.title),
            onTap: () {
              query = article.title;
              showResults(context);
            },
          );
        },
      );
    },
  );
}
}