import 'package:hive/hive.dart';

part 'favorite_article.g.dart';

@HiveType(typeId: 0)
class FavoriteArticle extends HiveObject {
  @HiveField(0)
  String title;
  @HiveField(1)
  String link;
  @HiveField(2)
  String author;
  @HiveField(3)
  String pubDate;
  @HiveField(4)
  String? description

  FavoriteArticle({
    required this.title,
    required this.link,
    required this.author,
    required this.pubDate,
    this.description
  });
}
