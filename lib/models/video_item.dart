import 'package:hive/hive.dart';

part 'video_item.g.dart';

@HiveType(typeId: 2)
class VideoItem {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String link;

  @HiveField(2)
  final String? thumbnailUrl;
  @HiveField(3)
  final String? description;
  @HiveField(4)
  final String? id;

  VideoItem({
    required this.title,
    required this.link,
    this.thumbnailUrl,
    this.description,
    this.id,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      title: json['title'] ?? 'Sans titre',
      link: json['link'],
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'],
      id: json['id'],
    );
  }
  Map<String, dynamic> toJson() => {
    'title': title,
    'link': link,
    'thumbnailUrl': thumbnailUrl,
    'description': description,
    'id': id,
  };
}
