import 'package:app_news/services/feed_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';


class ArticlePage extends StatefulWidget {
  final String url;
  const ArticlePage({required this.url, super.key});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final FeedService _service = FeedService();
  String? _htmlContent;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      final content = await _service.fetchCleanArticle(widget.url);
      if (mounted) setState(() { _htmlContent = content; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Article')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Erreur: $_error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Html(
                    data: _htmlContent,
                    style: {
                      "body": Style(fontSize: FontSize(16.0)),
                      "img": Style(width: Width(100, Unit.percent)),
                    },
                  ),
                ),
    );
  }
}
