import 'package:app_news/screens/search_delegate.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:app_news/services/search_service.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchService _searchService;

  @override
  void initState() {
    super.initState();
    _searchService = SearchService();
  }

  @override
  void dispose() {
    _searchService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche'),
        //backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NewsSearchDelegate(_searchService),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Appuyez sur l\'icône de recherche pour commencer'),
      ),
    );
  }
}