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
  @HiveField(5)
  final String? source;
  @HiveField(6)
  final DateTime? pubDate;
  @HiveField(7)
  final String? videoUrl;

  VideoItem({
    required this.title,
    required this.link,
    this.thumbnailUrl,
    this.description,
    this.id,
    this.source,
    this.pubDate,
    this.videoUrl,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      title: json['title'] ?? 'Sans titre',
      link: json['link'],
      thumbnailUrl: json['thumbnailUrl'],
      description: json['description'],
      id: json['id'],
      source: json['source'] ?? 'RSS',
      pubDate: json['pubDate'] != null ? DateTime.parse(json['pubDate']) : null,
      videoUrl: json['videoUrl'],
    );
  }
  Map<String, dynamic> toJson() => {
    'title': title,
    'link': link,
    'thumbnailUrl': thumbnailUrl,
    'description': description,
    'id': id,
    'source': source ?? 'Videos',
    'pubDate': pubDate?.toIso8601String(),
    'videoUrl': videoUrl,
  };
}
