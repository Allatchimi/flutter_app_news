import 'dart:math';
import 'package:app_news/screens/common/view_more_screen.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:app_news/screens/article/widgets/news_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/screens/profil/profile_page.dart';
import 'package:app_news/screens/profil/settings/settings_screen.dart';
import 'package:webfeed_plus/domain/rss_feed.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentIndex;
  final ValueListenable<int> unreadCount;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationsTap;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.currentIndex,
    required this.unreadCount,
    required this.onSearchTap,
    required this.onNotificationsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppColors.primaryColor,
      actions: [
        if (currentIndex != 1)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchTap,
          ),
        ValueListenableBuilder<int>(
          valueListenable: unreadCount,
          builder: (context, count, _) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: onNotificationsTap,
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        count.toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        if (currentIndex!=1)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
          ),
 ],
    );
  }
}

class SectionHeader1 extends StatelessWidget {
  final String title;
  final IconData? trailingIcon;
  final Color iconColor;
  
  const SectionHeader1({
    super.key,
    required this.title,
    this.trailingIcon = Icons.list,
    this.iconColor = AppColors.blackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: AppText(
            text: title,
            fontSize: 18.0,
            color: AppColors.blackColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(
            trailingIcon,
            color: iconColor.withOpacity(0.2),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final double titleFontSize;
  final Color titleColor;
  final double iconOpacity;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(15.0),
    this.titleFontSize = 18.0,
    this.titleColor = AppColors.blackColor,
    this.iconOpacity = 0.2,
  });

  factory SectionHeader.withIcon({
    Key? key,
    required String title,
    IconData icon = Icons.list,
    Color iconColor = AppColors.blackColor,
    double iconOpacity = 0.2,
    EdgeInsetsGeometry padding = const EdgeInsets.all(15.0),
    double titleFontSize = 18.0,
    Color titleColor = AppColors.blackColor,
  }) {
    return SectionHeader(
      key: key,
      title: title,
      padding: padding,
      titleFontSize: titleFontSize,
      titleColor: titleColor,
      trailing: Icon(
        icon,
        color: iconColor.withOpacity(iconOpacity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: padding,
          child: AppText(
            text: title,
            fontSize: titleFontSize,
            color: titleColor,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        if (trailing != null) Padding(
          padding: padding,
          child: trailing,
        ),
      ],
    );
  }
}

class ViewMoreButton extends StatelessWidget {
  final String? topic;
  final String topicUrl;
  final String Function(String) convertToSpaces;

  const ViewMoreButton({
    super.key,
    this.topic,
    required this.topicUrl,
    required this.convertToSpaces,
  });

  @override
  Widget build(BuildContext context) {
    if (topicUrl.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: InkWell(
            onTap: () => _navigateToViewMore(context),
            child: const AppText(
              text: "View More",
              fontSize: 18.0,
              color: AppColors.blackColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToViewMore(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewMore(
          getURL: topicUrl,
          name: convertToSpaces(topic!),
        ),
      )
    );
  }
}

class HomeSectionContent extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final RssFeed? feed;
  final VoidCallback onRetry;
  final ScrollPhysics scrollPhysics;
  final int itemCount;

  const HomeSectionContent({
    super.key,
    required this.isLoading,
    required this.error,
    required this.feed,
    required this.onRetry,
    this.itemCount = 2,
    this.scrollPhysics = const  NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoading();
    if (error != null) return _buildError(error!, onRetry);
    if (_hasNoArticles) return _buildEmptyState();
    
    return _buildArticlesList(scrollPhysics: scrollPhysics);
  }

  bool get _hasNoArticles =>
      feed == null || feed!.items == null || feed!.items!.isEmpty;

  Widget _buildLoading() {
    return const Center(child: CupertinoActivityIndicator());
  }

  Widget _buildError(String error, VoidCallback onRetry) {
    final isConnectionError = error.contains('No internet');
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isConnectionError ? Icons.wifi_off : Icons.error_outline,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          if (isConnectionError)
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('Aucun article disponible'),
    );
  }

  Widget _buildArticlesList({required ScrollPhysics scrollPhysics}) {
    return ListView.builder(
      physics: scrollPhysics,
      shrinkWrap: true,
      itemCount: min(itemCount, feed!.items!.length),
      itemBuilder: (context, index) {
        final item = feed!.items![index];
        return NewsWidget(
          title: item.title ?? '',
          subtitle: "",
          publishDate: item.pubDate?.toString() ?? "",
          author: item.author?.toString() ?? "",
          link: item.link?.toString() ?? "",
        );
      },
    );
  }
}
 