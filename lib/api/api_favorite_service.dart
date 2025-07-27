import 'package:dio/dio.dart';

class ApiFavoriteService {
  final dio = Dio(BaseOptions(baseUrl: "https://tonapi.com/api"));

  Future<void> addFavorite(String userId, String title, String link) async {
    await dio.post('/favorites', data: {
      "userId": userId,
      "title": title,
      "link": link,
    });
  }

  Future<void> removeFavorite(String userId, String link) async {
    await dio.delete('/favorites', data: {
      "userId": userId,
      "link": link,
    });
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final response = await dio.get('/favorites', queryParameters: {
      "userId": userId,
    });
    return List<Map<String, dynamic>>.from(response.data);
  }
}
