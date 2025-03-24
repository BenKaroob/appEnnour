import 'package:flutter/material.dart';
import '../utils/index.dart';

// Widget personnalisé pour une barre d'application cohérente
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool centerTitle;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double elevation;
  final Widget? leading;
  final bool showBismillah;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.centerTitle = true,
    this.onBackPressed,
    this.backgroundColor,
    this.textColor,
    this.elevation = 0,
    this.leading,
    this.showBismillah = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryColor;
    final txtColor = textColor ?? Colors.white;

    return AppBar(
      title: showBismillah
          ? Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: txtColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppConstants.bismillah,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 14,
              color: txtColor.withOpacity(0.9),
            ),
          ),
        ],
      )
          : Text(
        title,
        style: TextStyle(
          color: txtColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      elevation: elevation,
      leading: showBackButton
          ? (leading ?? IconButton(
        icon: const Icon(Icons.arrow_back),
        color: txtColor,
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ))
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Version transparente et avec scroll de la barre d'application
class ScrollableAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final ScrollController scrollController;
  final double expandedHeight;
  final Widget? background;
  final Color? backgroundColor;
  final Color? textColor;
  final bool showBackButton;

  const ScrollableAppBar({
    Key? key,
    required this.title,
    required this.scrollController,
    this.actions,
    this.expandedHeight = 200.0,
    this.background,
    this.backgroundColor,
    this.textColor,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppTheme.primaryColor;
    final txtColor = textColor ?? Colors.white;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: bgColor,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        color: txtColor,
        onPressed: () => Navigator.of(context).pop(),
      )
          : null,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: txtColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: background ?? Container(color: bgColor),
      ),
    );
  }
}