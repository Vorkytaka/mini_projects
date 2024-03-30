import 'package:flutter/material.dart';

import '../../mini_design.dart';

const double kTileMinHeight = 48;

class MiniListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  /// This field is used to indicate whenever we need to
  /// wrap this list tile with [Material].
  ///
  /// This is useful for cases, when our list tile is does have
  /// decoration above it, without direct material.
  final bool wrapWithMaterial;

  final EdgeInsetsGeometry contentPadding;

  const MiniListTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.wrapWithMaterial = true,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    super.key,
  });

  /// Hacky trick for use with material's right arrow
  ///
  /// It has it's own padding around.
  static const EdgeInsetsGeometry arrowEdgeInsets =
      EdgeInsetsDirectional.fromSTEB(16, 8, 10, 8);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleTextStyle = theme.textTheme.body;
    final title = DefaultTextStyle.merge(
      style: titleTextStyle,
      child: this.title,
    );

    Widget? subtitle;
    if (this.subtitle != null) {
      final subtitleTextStyle = theme.textTheme.subtitle;
      subtitle = DefaultTextStyle.merge(
        style: subtitleTextStyle,
        child: this.subtitle!,
      );
    }

    Widget? trailing;
    if (this.trailing != null) {
      final trailingTextStyle = theme.textTheme.subtitle!;
      final trailingIconTheme = IconThemeData(
        color: trailingTextStyle.color,
      );
      trailing = DefaultTextStyle.merge(
        style: trailingTextStyle,
        textAlign: TextAlign.end,
        child: IconTheme.merge(
          data: trailingIconTheme,
          child: this.trailing!,
        ),
      );
    }

    Widget child = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: kTileMinHeight,
      ),
      child: Padding(
        padding: contentPadding,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          subtitle,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 100, // ~ 1/3 of list tile
                ),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailing,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    child = InkWell(
      onTap: onTap,
      child: child,
    );

    if (wrapWithMaterial) {
      child = Material(
        type: MaterialType.transparency,
        child: child,
      );
    }

    return child;
  }
}
