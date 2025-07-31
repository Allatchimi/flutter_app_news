import 'package:hive/hive.dart';

part 'notification_item.g.dart';

@HiveType(typeId: 1)
class NotificationItem  extends HiveObject{
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final String payload;

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  bool isRead;

  @HiveField(6)
  final String type;

  @HiveField(7)
  final String? imageUrl;
  @HiveField(8)
  final String? link;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    required this.date,
    this.isRead = false,
    required this.type,
    this.imageUrl,
    this.link,
  });

  Future<void> save() async {
    final box = await Hive.openBox<NotificationItem>('notifications');
    await box.put(id, this);
  }
}
