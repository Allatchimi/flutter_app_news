import 'package:webfeed_plus/webfeed_plus.dart';

class ArticleModel {
  final String title;
  final String link;
  final String author;
  final String publishDate;
  final String description;

  ArticleModel({
    required this.title,
    required this.link,
    required this.author,
    required this.publishDate,
    required this.description,
  });

  factory ArticleModel.fromRssItem(RssItem item) {
    return ArticleModel(
      title: item.title ?? 'No title',
      link: item.link ?? '',
      author: item.dc?.creator ?? item.source?.url ?? 'Unknown',
      publishDate: item.pubDate?.toString() ?? '',
      description: item.description ?? '',
    );
  }

  // Factory method to create an instance from a JSON map
  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
        'author': author,
        'publishDate': publishDate,
        'description': description,
      };
      
  // Factory method to create an instance from a JSON map
  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
        title: json['title'],
        link: json['link'],
        author: json['author'],
        publishDate: json['publishDate'],
        description: json['description'],
      );
}
