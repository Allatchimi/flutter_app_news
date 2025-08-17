import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/screens/profil/profile_page.dart';
import 'package:app_news/screens/profil/settings/settings_screen.dart';
import 'package:flutter/services.dart';

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? extraActions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? elevation;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;
  final ShapeBorder? shape;
  final double? titleSpacing;
  final double? toolbarHeight;
  final TextStyle? titleTextStyle;
  final SystemUiOverlayStyle? systemOverlayStyle;

  // **Paramètres spécifiques pour le compteur de notifications**
  final int? currentIndex;
  final ValueListenable<int>? unreadNotifications;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationsTap;

  const GenericAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.extraActions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = false,
    this.backgroundColor,
    this.iconColor,
    this.elevation,
    this.onBackPressed,
    this.bottom,
    this.shape,
    this.titleSpacing,
    this.toolbarHeight,
    this.titleTextStyle,
    this.systemOverlayStyle,
    this.currentIndex,
    this.unreadNotifications,
    this.onSearchTap,
    this.onNotificationsTap,
  }) : assert(title == null || titleWidget == null,
            'Cannot provide both title and titleWidget');

  @override
  Size get preferredSize =>
      Size.fromHeight(toolbarHeight ?? kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title: _buildTitle(context, appBarTheme),
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor ?? AppColors.primaryColor,
      elevation: elevation ?? appBarTheme.elevation ?? 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context),
      actions: _buildActions(context),
      centerTitle: centerTitle,
      bottom: bottom,
      shape: shape,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      systemOverlayStyle: systemOverlayStyle ?? appBarTheme.systemOverlayStyle,
      iconTheme: IconThemeData(
        color: iconColor ?? appBarTheme.iconTheme?.color ?? AppColors.blackColor,
      ),
    );
  }

  Widget? _buildTitle(BuildContext context, AppBarTheme appBarTheme) {
    if (titleWidget != null) return titleWidget;
    if (title == null) return null;

    return Text(
      title!,
      style: titleTextStyle ??
          appBarTheme.titleTextStyle ??
          const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blackColor),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    final canPop = Navigator.canPop(context);
    if (!automaticallyImplyLeading || !canPop) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: onBackPressed ?? () => Navigator.maybePop(context),
    );
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> actions = [];

    // Bouton recherche
    if (currentIndex != null &&
        currentIndex != 1 &&
        onSearchTap != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap,
        ),
      );
    }

    // Icône notifications avec compteur
    if (unreadNotifications != null && onNotificationsTap != null) {
      actions.add(
        ValueListenableBuilder<int>(
          valueListenable: unreadNotifications!,
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
      );
    }

    // Boutons profil / paramètres
    if (currentIndex != null) {
      if (currentIndex != 4) {
        actions.add(
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) =>  ProfilePage()),
            ),
          ),
        );
      } else {
        actions.add(
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        );
      }
    }

    // Actions supplémentaires
    if (extraActions != null) actions.addAll(extraActions!);

    return actions.isEmpty ? null : actions;
  }
}
