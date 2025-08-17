import 'dart:async';
import 'dart:io';

import 'package:app_news/screens/article/widgets/news_widget.dart';
import 'package:app_news/screens/home/widgets/home_screen_widgets.dart';
import 'package:app_news/services/home_service.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/handleException.dart';
import 'package:app_news/widgets/generic_app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webfeed_plus/webfeed_plus.dart';

class ViewMore extends StatefulWidget {
  final String name;
  final String getURL;

  const ViewMore({super.key, required this.getURL, required this.name});

  @override
  _ViewMoreState createState() => _ViewMoreState();
}

class _ViewMoreState extends State<ViewMore> {
  final HomeService _homeService = HomeService();
  RssFeed? _feed;
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    if (_isDisposed) return;

    setState(() => _isLoading = true);

    try {
      final feed = await _homeService
          .fetchFeedWithRetry(widget.getURL)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('UI timeout'),
          );

      if (_isDisposed || !mounted) return;

      setState(() {
        _feed = feed;
        _isLoading = false;
        _error = null;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _error = 'Temps de réponse dépassé');
    } on SocketException {
      if (!mounted) return;
      setState(() => _error = 'Problème de connexion internet');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Erreur inattendue');
      debugPrint('Erreur RSS: $e');
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _homeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(
        title: widget.name,
        iconColor: AppColors.blackColor,
        backgroundColor: AppColors.primaryColor,
        onBackPressed: () => Navigator.pop(context),
        extraActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadFeed,
          ),
          IconButton(icon: const Icon(Icons.share), onPressed: _shareArticle),
        ],
      ),
      body: _feed?.items != null
          ? HomeSectionContent(
              isLoading: _isLoading,
              error: _error,
              feed: _feed,
              onRetry: _loadFeed,
              itemCount: _feed?.items?.length ?? 0,
              scrollPhysics: const AlwaysScrollableScrollPhysics(),
            )
          : const Center(child: CupertinoActivityIndicator()),
    );
  }

  void _shareArticle() {
    Share.share('Découvrez cet article: ${_feed?.items?.first.link}');
  }

  final Set<String> _savedArticles = {};

void _toggleSave(String link) async {
  if (link.isEmpty) return;

  final bool wasSaved = _savedArticles.contains(link);
  final completer = Completer();

  setState(() {
    wasSaved ? _savedArticles.remove(link) : _savedArticles.add(link);
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(wasSaved ? 'Article retiré' : 'Article sauvegardé'),
      action: SnackBarAction(
        label: 'ANNULER',
        onPressed: () {
          completer.complete(false);
          setState(() {
            wasSaved ? _savedArticles.add(link) : _savedArticles.remove(link);
          });
        },
      ),
      duration: const Duration(seconds: 2),
    ),
  );

  await completer.future;
  //_persistSavedArticles(); // Sauvegarde seulement si pas d'annulation
}
}
