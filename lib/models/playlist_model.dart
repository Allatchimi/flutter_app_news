

import 'package:hive/hive.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 4)
class Playlist {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String url;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String? thumbnail;
  @HiveField(4)
  final String id;

  Playlist({required this.title, required this.url,  this.description, this.thumbnail, required this.id});

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      title: json['title'] ?? 'Sans titre',
      url: json['url'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      id: json['id']
    );
  }
    Map<String, dynamic> toJson() => {
      'title': title,
      'url': url,
      'thumbnail': thumbnail,
      'description': description,
      'id': id
    };
}
