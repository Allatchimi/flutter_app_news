import 'package:flutter/material.dart';
import 'package:app_news/utils/app_colors.dart'; // Adaptez selon votre projet
import 'package:app_news/widgets/app_text.dart';
import 'package:flutter/services.dart'; // Votre widget texte personnalisé

class GenericAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Propriétés principales
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
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
  final bool? primary;
  final double? toolbarHeight;
  final TextStyle? titleTextStyle;
  final SystemUiOverlayStyle? systemOverlayStyle;

  const GenericAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
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
    this.primary,
    this.toolbarHeight,
    this.titleTextStyle,
    this.systemOverlayStyle,
  }) : assert(title == null || titleWidget == null,
            'Cannot provide both title and titleWidget');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title: _buildTitle(context, appBarTheme),
      backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
      elevation: elevation ?? appBarTheme.elevation ?? 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: _buildLeading(context),
      actions: _buildActions(),
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

    return AppText(
      text: title!,
      color: titleTextStyle?.color ??
          appBarTheme.titleTextStyle?.color ??
          AppColors.blackColor,
      fontSize: titleTextStyle?.fontSize ??
          appBarTheme.titleTextStyle?.fontSize ??
          18.0,
      fontWeight: titleTextStyle?.fontWeight ??
          appBarTheme.titleTextStyle?.fontWeight ??
          FontWeight.normal,
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

  List<Widget>? _buildActions() {
    if (actions == null || actions!.isEmpty) return null;
    return actions;
  }

  @override
  Size get preferredSize => Size.fromHeight(
      toolbarHeight ?? kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}