/// In this file we contain everything about our implementation of group of items

import 'package:flutter/material.dart';
import 'package:slivers/slivers.dart' show SliverClipRRect;

import '../../mini_design.dart';

/// Border radius of groups.
///
/// Currently just copy-paste from iOS guidelines.
const kGroupBorderRadius = BorderRadius.all(Radius.circular(10));

const kGroupHorizontalPadding = EdgeInsets.symmetric(
  horizontal: 16,
);

class MiniGroupDivider extends StatelessWidget {
  final double indent;

  const MiniGroupDivider({
    this.indent = 58,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final height = 1 / devicePixelRatio;
    final theme = Theme.of(context);

    // TODO(Vorkytaka): Don't use Divider
    return Divider(
      height: height,
      thickness: height,
      indent: indent,
      color: theme.dividerColor,
    );
  }
}

class MiniGroup extends StatelessWidget {
  final Widget? header;
  final Widget child;

  const MiniGroup({
    required this.child,
    this.header,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) MiniGroupHeader(header: header!),
        Material(
          color: theme.colorScheme.surface,
          borderRadius: kGroupBorderRadius,
          clipBehavior: Clip.hardEdge,
          child: child,
        ),
      ],
    );
  }
}

class SliverMiniGroup extends StatelessWidget {
  final Widget? header;
  final Widget sliver;

  const SliverMiniGroup({
    required this.sliver,
    this.header,
    super.key,
  });

  static Decoration getGroupDecoration({required ThemeData theme}) =>
      BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: kGroupBorderRadius,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverMainAxisGroup(
      slivers: [
        if (header != null)
          SliverToBoxAdapter(
            child: MiniGroupHeader(header: header!),
          ),
        SliverClipRRect(
          borderRadius: kGroupBorderRadius,
          child: DecoratedSliver(
            decoration: getGroupDecoration(theme: theme),
            sliver: sliver,
          ),
        ),
      ],
    );
  }
}

class MiniGroupHeader extends StatelessWidget {
  final Widget header;

  const MiniGroupHeader({
    required this.header,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final headerTextStyle = theme.textTheme.label?.copyWith(
      letterSpacing: 0,
    );
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 6),
      child: DefaultTextStyle.merge(
        style: headerTextStyle,
        child: header,
      ),
    );
  }
}
