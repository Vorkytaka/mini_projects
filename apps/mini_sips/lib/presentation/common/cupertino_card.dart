import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinoCard extends StatelessWidget {
  final Widget? icon;
  final Widget title;
  final Widget? trailing;
  final Widget? bottom;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const CupertinoCard({
    required this.title,
    super.key,
    this.icon,
    this.trailing,
    this.bottom,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return Material(
      type: backgroundColor == null
          ? MaterialType.transparency
          : MaterialType.canvas,
      color: backgroundColor,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(
              top: 14,
              bottom: 14,
              start: 20,
              end: 14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                          if (icon != null) ...[
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: Center(
                                child: IconTheme.merge(
                                  data: const IconThemeData(
                                    size: 16,
                                  ),
                                  child: icon!,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          DefaultTextStyle(
                            style: cupertinoTheme.textTheme.textStyle,
                            child: title,
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
                if (bottom != null) ...[
                  const SizedBox(height: 12),
                  bottom!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
