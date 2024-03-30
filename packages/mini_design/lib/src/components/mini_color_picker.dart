import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class MiniColorPicker extends StatelessWidget {
  static const List<MaterialColor> primaryColors = <MaterialColor>[
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
  ];

  final List<Color> colors;
  final Color? selectedColor;
  final ValueChanged<Color>? onChanged;

  const MiniColorPicker({
    Key? key,
    this.colors = primaryColors,
    this.selectedColor,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO(Vorkytaka): Draw colors as a grid for desktops, because we cannot scroll horizontally with mouse
    // TODO(Vorkytaka): maybe somehow count real offset to the selected child and scroll by myself
    return SizedBox(
      height: 56,
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
          },
        ),
        child: ListView.builder(
          cacheExtent: 9999,
          itemCount: primaryColors.length,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, i) {
            final color = primaryColors[i];
            final isSelected = selectedColor?.value == color.value;
            return _Item(
              color: color,
              isSelected: isSelected,
              onChanged: onChanged,
            );
          },
        ),
      ),
    );
  }
}

class _Item extends StatefulWidget {
  final Color color;
  final bool isSelected;
  final ValueChanged<Color>? onChanged;

  const _Item({
    required this.color,
    required this.isSelected,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  @override
  void initState() {
    super.initState();
    if (widget.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Scrollable.ensureVisible(context, alignment: 0.5);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Center(
        child: Ink(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: AnimatedSize(
            duration: kThemeChangeDuration,
            curve: Curves.easeInOutBack,
            child: SizedBox(
              width: widget.isSelected ? 48 : 40,
              height: widget.isSelected ? 48 : 40,
              child: InkWell(
                onTap: widget.onChanged == null
                    ? null
                    : () => widget.onChanged!(widget.color),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: AnimatedSwitcher(
                  duration: kThemeChangeDuration,
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(
                      scale: anim,
                      child: FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: anim,
                            curve: const Interval(0.5, 1),
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: widget.isSelected
                      ? Icon(
                          Icons.done,
                          color: ThemeData.estimateBrightnessForColor(
                                      widget.color) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
