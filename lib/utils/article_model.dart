class ArticleModel {
  final String title;
  final String link;

  // Constructor
  ArticleModel({required this.title, required this.link});

  // Factory method to create an instance from a JSON map
  Map<String, dynamic> toJson() => {
        'title': title,
        'link': link,
      };
      
  // Factory method to create an instance from a JSON map
  factory ArticleModel.fromJson(Map<String, dynamic> json) => ArticleModel(
        title: json['title'],
        link: json['link'],
      );
}
