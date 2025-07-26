import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/widgets/news_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed_plus/webfeed_plus.dart';

class ViewMore extends StatefulWidget {
  final String name;
  final String getURL;
  const ViewMore({super.key, required this.getURL, required this.name});

  @override
  _ViewMoreState createState() => _ViewMoreState();
}

class _ViewMoreState extends State<ViewMore> {
  RssFeed? feed;
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final List<RssItem> _allItems = [];
  bool _isDisposed = false; // Nouveau flag pour suivre l'état de disposition

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _isDisposed = true; // Marquer comme disposé
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (_isDisposed) return;
    
    try {
      _safeSetState(() => isLoading = true);
      final response = await http.get(Uri.parse(widget.getURL));

      if (_isDisposed) return;
      
      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('<?xml') || body.startsWith('<rss')) {
          final parsedFeed = RssFeed.parse(body);
          _safeSetState(() {
            feed = parsedFeed;
            _allItems.addAll(parsedFeed.items ?? []);
          });
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        print("Erreur RSS: $e");
      }
    } finally {
      _safeSetState(() => isLoading = false);
    }
  }

  void _onScroll() {
    if (_isDisposed) return;
    if (_scrollController.position.pixels == 
        _scrollController.position.maxScrollExtent && 
        !isLoading && 
        hasMore) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isDisposed || isLoading || !hasMore) return;
    
    _safeSetState(() => isLoading = true);
    
    try {
      final nextPageUrl = '${widget.getURL}&page=${currentPage + 1}';
      final response = await http.get(Uri.parse(nextPageUrl));
      
      if (_isDisposed) return;
      
      if (response.statusCode == 200) {
        final newFeed = RssFeed.parse(response.body);
        if (newFeed.items?.isEmpty ?? true) {
          _safeSetState(() => hasMore = false);
        } else {
          _safeSetState(() {
            _allItems.addAll(newFeed.items ?? []);
            currentPage++;
          });
        }
      }
    } catch (e) {
      if (!_isDisposed) {
        print("Erreur chargement supplémentaire: $e");
      }
    } finally {
      _safeSetState(() => isLoading = false);
    }
  }

  // Méthode helper pour appeler setState de manière sécurisée
  void _safeSetState(VoidCallback fn) {
    if (!_isDisposed && mounted) {
      setState(fn);
    }
  }

  String? _extractImageUrl(String? html) {
    if (html == null) return null;
    try {
      final regex = RegExp(r'<img[^>]+src="([^">]+)"');
      final match = regex.firstMatch(html);
      return match?.group(1);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText(
          text: widget.name,
          fontSize: 18.0,
          color: AppColors.blackColor,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_allItems.isEmpty) {
      return Center(
        child: isLoading 
            ? const CupertinoActivityIndicator() 
            : const Text('Aucun article disponible'),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isDisposed &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent && 
            !isLoading && 
            hasMore) {
          _loadMoreData();
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _allItems.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _allItems.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }

          final item = _allItems[index];
          return _buildArticleItem(item);
        },
      ),
    );
  }

  Widget _buildArticleItem(RssItem item) {
    final imageUrl = _extractImageUrl(item.description);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: InkWell(
        onTap: () => _openArticle(item.link),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null) _buildImageThumbnail(imageUrl),
            Expanded(
              child: NewsWidget(
                title: item.title ?? 'Sans titre',
                subtitle: item.description ?? '',
                publishDate: item.pubDate?.toString() ?? '',
                author: item.source?.url.toString() ?? 'Auteur inconnu',
                link: item.link ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
          ),
          errorWidget: (context, url, error) => Container(
            width: 100,
            height: 100,
            color: Colors.grey[200],
            child: const Icon(Icons.article),
          ),
        ),
      ),
    );
  }

  void _openArticle(String? url) {
    if (url == null || url.isEmpty || _isDisposed) return;
    // Implémentez votre logique de navigation ici
  }
}