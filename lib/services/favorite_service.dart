import 'package:app_news/models/favorite_article.dart';
import 'package:app_news/utils/helper/hive_box.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:hive/hive.dart';

class FavoriteService {
  static final Box<FavoriteArticle> _box = Hive.box<FavoriteArticle>(HiveBoxes.favorites);

  // Génère une clé MD5 courte à partir du lien
  static String _generateKey(String link) {
    return md5.convert(utf8.encode(link)).toString();
  }

  static List<FavoriteArticle> getFavorites() {
    return _box.values.toList();
  }

  static void addToFavorites(FavoriteArticle article) {
    final key = _generateKey(article.link);
    _box.put(key, article);
  }

  static void removeFromFavorites(String link) {
    final key = _generateKey(link);
    _box.delete(key);
  }

  static bool isFavorite(String link) {
    final key = _generateKey(link);
    return _box.containsKey(key);
  }
}
