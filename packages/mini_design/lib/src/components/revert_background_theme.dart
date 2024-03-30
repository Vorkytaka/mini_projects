import 'package:flutter/material.dart';

/// This widget just revert [ThemeData]'s [ColorScheme.surface] with [ColorScheme.background]
///
/// We use that for handle card UI.
///
/// On the screen where main elements is card – we want to highlight them.
class RevertBackgroundTheme extends StatelessWidget {
  final Widget child;

  const RevertBackgroundTheme({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final revertTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        surface: theme.colorScheme.background,
        background: theme.colorScheme.surface,
      ),
      scaffoldBackgroundColor: theme.colorScheme.surface,
    );

    return Theme(
      data: revertTheme,
      child: child,
    );
  }
}
