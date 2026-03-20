import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class BaseSliverScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> slivers;
  final double expandedHeight;
  final bool pinned;
  final ScrollPhysics? physics;
  final List<Widget>? actions;
  final Color? backgroundColor;

  const BaseSliverScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.subtitle,
    this.expandedHeight = 170,
    this.pinned = true,
    this.physics,
    this.actions,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final TargetPlatform platform = Theme.of(context).platform;

    final ScrollPhysics resolvedPhysics =
        physics ??
        ((platform == TargetPlatform.iOS || platform == TargetPlatform.macOS)
            ? const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              )
            : const ClampingScrollPhysics());

    return Scaffold(
      backgroundColor:
          backgroundColor ??
          (isDarkMode ? AppColors.darkBlue : AppColors.lightBackground),
      body: CustomScrollView(
        physics: resolvedPhysics,
        slivers: [
          SliverAppBar(
            pinned: pinned,
            stretch: true,
            expandedHeight: expandedHeight,
            backgroundColor: isDarkMode
                ? AppColors.darkBlue
                : AppColors.lightBackground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            actions: actions,
            title: Text(title),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? [
                            AppColors.lightBlue.withValues(alpha: 0.24),
                            Colors.transparent,
                          ]
                        : [AppColors.lightBackground, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : AppColors.textDark,
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              subtitle!,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          ...slivers,
        ],
      ),
    );
  }
}
