import 'package:hive/hive.dart';
import 'package:webfeed_plus/webfeed_plus.dart';
part 'article_model.g.dart';

@HiveType(typeId: 3)
class ArticleModel {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final String link;
  @HiveField(3)
  final DateTime? publishDate;
  @HiveField(4)
  final String? imageUrl;
  @HiveField(5)
  final String? author;


  ArticleModel({
    required this.title,
    required this.description,
    required this.link,
    this.publishDate,
    this.imageUrl,
    this.author,
 
  });

  factory ArticleModel.fromRssItem(RssItem item) {
    return ArticleModel(
      title: item.title ?? 'Sans titre',
      description: item.description ?? '',
      link: item.link ?? '',
      publishDate: item.pubDate,
      author: item.author,
      imageUrl: _extractImageUrl(item),
    );
  }

  // Factory method to create an instance from a JSON map
  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'link': link,
        'publishDate': publishDate,
        'imageUrl': imageUrl, 
        'author': author,
        
      };
      
  // Factory method to create an instance from a JSON map
  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
        title: json['title'],
        link: json['link'],
        author: json['author'],
        publishDate: json['publishDate'],
        description: json['description'],
        imageUrl: json['imageUrl'],
        
      );

    static String? _extractImageUrl(RssItem item) {
    // Extraction d'image depuis le contenu
    final regex = RegExp(r'<img[^>]+src="([^">]+)"');
    final match = regex.firstMatch(item.description ?? '');
    return match?.group(1);
  }
}
