import 'package:app_news/models/favorite_article.dart';
import 'package:hive/hive.dart';

class FavoriteService {
  static final Box<FavoriteArticle> _box = Hive.box<FavoriteArticle>('favorites');

  static List<FavoriteArticle> getFavorites() {
    return _box.values.toList();
  }

  static void addToFavorites(FavoriteArticle article) {
    _box.put(article.link, article); // Le lien est utilisé comme identifiant unique
  }

  static void removeFromFavorites(String link) {
    _box.delete(link);
  }

  static bool isFavorite(String link) {
    return _box.containsKey(link);
  }
}
