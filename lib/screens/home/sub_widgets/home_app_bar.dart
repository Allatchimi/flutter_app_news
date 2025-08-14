import 'package:app_news/screens/profil/profil_screen.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/widgets/app_text.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color titleColor;
  final double titleSize;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color backgroundColor;
  final VoidCallback? onProfilePressed;

  const HomeAppBar({
    super.key,
    this.title = "Home Screen",
    this.titleColor = AppColors.blackColor,
    this.titleSize = 18.0,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 5,
    this.backgroundColor = AppColors.primaryColor,
    this.onProfilePressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: AppText(
        text: title,
        color: titleColor,
        fontSize: titleSize,
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: leading,
      centerTitle: centerTitle,
      actions: actions ?? _defaultActions(context),
    );
  }

  List<Widget> _defaultActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(
          Icons.account_circle_outlined,
          color: AppColors.blackColor,
        ),
        onPressed: onProfilePressed ?? () {
          // Navigation par défaut si onProfilePressed n'est pas fourni
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
        },
      ),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}