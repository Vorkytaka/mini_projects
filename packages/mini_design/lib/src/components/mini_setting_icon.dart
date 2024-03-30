import 'package:flutter/material.dart';

class MiniSettingIcon extends StatelessWidget {
  final Widget icon;
  final Color color;

  const MiniSettingIcon({
    required this.icon,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    assert(ThemeData.estimateBrightnessForColor(color) == Brightness.dark);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: color,
      ),
      child: SizedBox(
        width: 30,
        height: 30,
        child: IconTheme(
          data: const IconThemeData(
            size: 24,
            color: Colors.white,
          ),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }
}
