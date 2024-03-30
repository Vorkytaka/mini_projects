import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

const _checkBoxWidth = 24.0;
const _checkBoxStrokeWidth = 2.0;
const _duration = Duration(milliseconds: 300);

/// A mini Checkbox.
///
/// This widget wraps [MiniCheckboxRaw] to handle animation and on change tap.
/// Can be used just like Material [Checkbox].
class MiniCheckbox extends StatefulWidget {
  final Color? fillColor;
  final Color? checkColor;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final int bubbleCount;
  final List<Color>? bubbleColors;
  final double size;

  const MiniCheckbox({
    required this.value,
    super.key,
    this.fillColor,
    this.checkColor,
    this.shape,
    this.side,
    this.onChanged,
    this.bubbleCount = 6,
    this.bubbleColors,
    this.size = _checkBoxWidth,
  });

  @override
  State<MiniCheckbox> createState() => _MiniCheckboxState();
}

class _MiniCheckboxState extends State<MiniCheckbox>
    with SingleTickerProviderStateMixin {
  late AnimationController _positionController;
  late CurvedAnimation _position;

  @override
  void initState() {
    super.initState();

    _positionController = AnimationController(
      vsync: this,
      value: widget.value == false ? 0.0 : 1.0,
      duration: _duration,
    );
    _position = CurvedAnimation(
      parent: _positionController,
      curve: Curves.linear,
      reverseCurve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(MiniCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animateToValue();
    }
  }

  @override
  void dispose() {
    _positionController.dispose();
    super.dispose();
  }

  void _animateToValue() {
    if (widget.value) {
      _positionController.forward();
    } else {
      _positionController.reverse();
    }
  }

  void _onTap() {
    if (widget.onChanged == null) {
      return;
    }

    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    return MiniCheckboxRaw(
      checkColor: widget.checkColor,
      fillColor: widget.fillColor,
      shape: widget.shape,
      side: widget.side,
      onTap: _onTap,
      checked: _position,
      size: widget.size,
      bubbleColors: widget.bubbleColors,
      bubbleCount: widget.bubbleCount,
    );
  }
}

/// A raw mini Checkbox.
///
/// Widget that represent basis for mini checkbox.
/// For using this out-of-the-box see [MiniCheckbox].
class MiniCheckboxRaw extends StatefulWidget {
  final Color? fillColor;
  final Color? checkColor;
  final OutlinedBorder? shape;
  final BorderSide? side;
  final VoidCallback? onTap;
  final Animation<double> checked;
  final int bubbleCount;
  final List<Color>? bubbleColors;

  /// Size of both side of checkbox
  final double size;

  /// Size of the tappable area size.
  ///
  /// Can be useful for case, when we want to draw a small checkbox,
  /// but with biggest tap area.
  ///
  /// By default if [kMinInteractiveDimension].
  ///
  /// If [tapAreaSize] is smaller than [size], then [size] will be used.
  final double tapAreaSize;

  const MiniCheckboxRaw({
    required this.checked,
    super.key,
    this.fillColor,
    this.checkColor,
    this.shape,
    this.side,
    this.onTap,
    this.bubbleCount = 6,
    this.bubbleColors,
    this.size = _checkBoxWidth,
    this.tapAreaSize = kMinInteractiveDimension,
  }) : assert(bubbleCount >= 0);

  @override
  State<MiniCheckboxRaw> createState() => _MiniCheckboxRawState();
}

class _MiniCheckboxRawState extends State<MiniCheckboxRaw> {
  final _painter = _MiniCheckboxPainter();
  List<double> _bubbleAngles = const [];

  @override
  void initState() {
    super.initState();
    _updateBubblesAngles();
  }

  @override
  void didUpdateWidget(covariant MiniCheckboxRaw oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.bubbleCount != oldWidget.bubbleCount) {
      _updateBubblesAngles();
    }
  }

  void _updateBubblesAngles() {
    // For now it's not handle [MiniCheckboxThemeData.bubbleCount]
    // Move to the build?
    final angleStep = 360 / widget.bubbleCount;
    _bubbleAngles = List.generate(widget.bubbleCount, (i) {
      return i * angleStep;
    }, growable: false);
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkboxThemeData = MiniCheckboxTheme.maybeOf(context);
    final defaults = _MiniCheckboxDefaults(context);

    final resolvedFillColor =
        widget.fillColor ?? checkboxThemeData?.fillColor ?? defaults.fillColor;
    final resolvedCheckColor = widget.checkColor ??
        checkboxThemeData?.checkColor ??
        defaults.checkColor;
    final resolvedSide =
        (widget.side ?? checkboxThemeData?.side ?? defaults.side)
            .copyWith(color: resolvedFillColor);
    final resolvedShape =
        widget.shape ?? checkboxThemeData?.shape ?? defaults.shape;
    final resolvedBubbleColors = widget.bubbleColors ??
        checkboxThemeData?.bubbleColors ??
        defaults.bubbleColors;

    final double elementSize = max(
      widget.tapAreaSize,
      widget.size,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: CustomPaint(
        painter: _painter
          ..position = widget.checked
          ..fillColor = resolvedFillColor
          ..checkColor = resolvedCheckColor
          ..side = resolvedSide
          ..shape = resolvedShape
          ..bubbleAngles = _bubbleAngles
          ..bubbleColors = resolvedBubbleColors
          ..size = widget.size,
        size: Size.square(elementSize),
      ),
    );
  }
}

class _MiniCheckboxPainter extends ChangeNotifier implements CustomPainter {
  Animation<double> get position => _position!;
  Animation<double>? _position;

  set position(Animation<double> value) {
    if (value == _position) {
      return;
    }
    _position?.removeListener(notifyListeners);
    value.addListener(notifyListeners);
    _position = value;
    notifyListeners();
  }

  Color get fillColor => _fillColor!;
  Color? _fillColor;

  set fillColor(Color value) {
    if (_fillColor == value) {
      return;
    }
    _fillColor = value;
    notifyListeners();
  }

  Color get checkColor => _checkColor!;
  Color? _checkColor;

  set checkColor(Color value) {
    if (_checkColor == value) {
      return;
    }
    _checkColor = value;
    notifyListeners();
  }

  BorderSide get side => _side!;
  BorderSide? _side;

  set side(BorderSide value) {
    if (_side == value) {
      return;
    }
    _side = value;
    notifyListeners();
  }

  OutlinedBorder get shape => _shape!;
  OutlinedBorder? _shape;

  set shape(OutlinedBorder value) {
    if (_shape == value) {
      return;
    }
    _shape = value;
    notifyListeners();
  }

  List<double> get bubbleAngles => _bubbleAngles!;
  List<double>? _bubbleAngles;

  set bubbleAngles(List<double> value) {
    if (_bubbleAngles == value) {
      return;
    }
    _bubbleAngles = value;
    notifyListeners();
  }

  List<Color> get bubbleColors => _bubbleColors!;
  List<Color>? _bubbleColors;

  set bubbleColors(List<Color> value) {
    if (_bubbleColors == value) {
      return;
    }
    _bubbleColors = value;
    notifyListeners();
  }

  /// Size of checkbox itself.
  /// Both width and height.
  double get size => _size!;
  double? _size;

  /// Width of checkmark stroke
  double? _checkmarkWidth;

  /// Radius of the bubbles on the t = 1
  double? _bubbleRadius;

  /// Starting point of checkmark on the checkbox
  Offset? _startPoint;

  /// Middle point of checkmark on the checkbox
  Offset? _midPoint;

  /// Control point of the second part of checkmark on the checkbox
  Offset? _controlPoint;

  /// End point of checkmark on the checkbox
  Offset? _endPoint;

  set size(double value) {
    if (_size == value) {
      return;
    }
    _size = value;
    _checkmarkWidth = value / 8;
    _bubbleRadius = value / 6;
    _startPoint = Offset(value * 0.22, value * 0.35);
    _midPoint = Offset(value * 0.5, value * 0.75);
    _controlPoint = Offset(value * 0.65, value * 0.4);
    _endPoint = Offset(value * 1.1, value * -0.1);
    notifyListeners();
  }

  // --- --- ---

  _MiniCheckboxPainter();

  Rect _outerRectAt(Offset origin, double t) {
    final inset = 1.0 - (t - 0.5).abs() * 2.0;
    final rectSize = size - inset * size;
    final offset = (size - rectSize) / 2;
    final rect = Rect.fromLTWH(
      origin.dx + offset,
      origin.dy + offset,
      rectSize,
      rectSize,
    );
    return rect;
  }

  Rect _outerStrokeAt(Offset origin, double t) {
    final inset = 1.0 - (t - 0.5).abs() * 2.0;
    final rectSize = size - inset * _checkBoxStrokeWidth;
    final offset = (size - rectSize) / 2;
    final rect = Rect.fromLTWH(
      origin.dx + offset,
      origin.dy + offset,
      rectSize,
      rectSize,
    );
    return rect;
  }

  void _drawCheckmark(Canvas canvas, Paint paint, Offset origin, double t) {
    assert(t >= 0 && t <= 1.0);

    final path = Path();

    if (t < 0.5) {
      // On first half of animation we draw just left line
      final strokeT = t * 2.0;
      final drawMid = Offset.lerp(_startPoint, _midPoint, strokeT)!;
      path.moveTo(origin.dx + _startPoint!.dx, origin.dy + _startPoint!.dy);
      path.lineTo(origin.dx + drawMid.dx, origin.dy + drawMid.dy);
    } else {
      // On second half of animation we fully draw left line
      // and animate second curve line
      final strokeT = (t - 0.5) * 2.0;

      // For draw Bezier curve at the moment t we:
      // 1) Interpolate control point by line from [mid] to [control]
      // 2) Interpolate end point by https://en.wikipedia.org/wiki/Bézier_curve#Linear_Bézier_curves
      //    Thanks to the @polodarb & @happy_bracket for finding this formula
      final x = (1 - strokeT) * (1 - strokeT) * _midPoint!.dx +
          2 * (1 - strokeT) * strokeT * _controlPoint!.dx +
          strokeT * strokeT * _endPoint!.dx;
      final y = (1 - strokeT) * (1 - strokeT) * _midPoint!.dy +
          2 * (1 - strokeT) * strokeT * _controlPoint!.dy +
          strokeT * strokeT * _endPoint!.dy;

      final drawControl = Offset.lerp(_midPoint, _controlPoint, strokeT)!;

      path.moveTo(origin.dx + _startPoint!.dx, origin.dy + _startPoint!.dy);
      path.lineTo(origin.dx + _midPoint!.dx, origin.dy + _midPoint!.dy);
      path.quadraticBezierTo(
        origin.dx + drawControl.dx,
        origin.dy + drawControl.dy,
        origin.dx + x,
        origin.dy + y,
      );
    }

    canvas.drawPath(path, paint);
  }

  void _drawBubbles(Canvas canvas, Size canvasSize, double t) {
    assert(t >= 0 && t <= 1);

    // We draw circles only when we check this checkbox
    if (position.status != AnimationStatus.forward) {
      return;
    }

    // Happy for us we draw circles by center
    // So, we doesn't need an origin point
    final centerPoint = Offset(
      canvasSize.width / 2,
      canvasSize.height / 2,
    );

    final radius = size * t;
    // For now we hardcode this
    final bubbleSize = _bubbleRadius! * t;

    final paint = Paint();

    // We recount [t] for colors because without that
    // colors go to the [Colors.transparent] to fast
    final colorT = (t - 0.5) * 2;
    for (var i = 0; i < bubbleAngles.length; i++) {
      final angle = bubbleAngles[i];
      final color = Color.lerp(
        bubbleColors[i % bubbleColors.length],
        Colors.transparent,
        colorT,
      )!;
      paint.color = color;
      final x = radius * sin(pi * 2 * angle / 360);
      final y = radius * cos(pi * 2 * angle / 360);
      final circleOffset = Offset(x, y) + centerPoint;
      canvas.drawCircle(circleOffset, bubbleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final t = position.value;

    final checkmarkPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _checkmarkWidth!
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final boxPaint = Paint()..color = fillColor;

    /// The point at the canvas with what we draw our checkbox at the middle
    final origin = canvasSize / 2.0 - Size.square(size) / 2.0 as Offset;

    final checkmarkT = (t - 0.5) * 2.0;

    if (t >= 0.5) {
      checkmarkPaint.color = fillColor;
      _drawCheckmark(canvas, checkmarkPaint, origin, checkmarkT);
    }

    final outer = _outerRectAt(origin, t);

    shape.copyWith(side: side).paint(canvas, _outerStrokeAt(origin, t));

    canvas.saveLayer(outer, boxPaint);
    if (t >= 0.5) {
      canvas.drawPath(shape.getOuterPath(outer), boxPaint);
      checkmarkPaint
        ..color = checkColor
        ..blendMode = BlendMode.srcIn;
      _drawCheckmark(canvas, checkmarkPaint, origin, checkmarkT);
    }

    canvas.restore();

    if (t >= 0.5) {
      _drawBubbles(canvas, canvasSize, t);
    }
  }

  @override
  bool? hitTest(Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;

  @override
  void dispose() {
    _position?.removeListener(notifyListeners);
    super.dispose();
  }
}

class MiniCheckboxTheme extends InheritedWidget {
  final MiniCheckboxThemeData data;

  const MiniCheckboxTheme({
    required this.data,
    required super.child,
    super.key,
  });

  /// Return closest [MiniCheckboxThemeData].
  ///
  /// If there is no [MiniCheckboxTheme] above this [context],
  /// then return [MiniCheckboxThemeData] of [Theme].
  static MiniCheckboxThemeData? maybeOf(BuildContext context) {
    final miniCheckboxTheme =
        context.dependOnInheritedWidgetOfExactType<MiniCheckboxTheme>();
    return miniCheckboxTheme?.data ??
        Theme.of(context).extension<MiniCheckboxThemeData>();
  }

  /// Return closest [MiniCheckboxThemeData].
  ///
  /// If there is no [MiniCheckboxTheme] above this [context],
  /// then return [MiniCheckboxThemeData] of [Theme].
  ///
  /// If there is no [MiniCheckboxThemeData] inside [Theme],
  /// then return [_MiniCheckboxDefaults].
  static MiniCheckboxThemeData of(BuildContext context) {
    final miniCheckboxTheme =
        context.dependOnInheritedWidgetOfExactType<MiniCheckboxTheme>();
    return miniCheckboxTheme?.data ??
        Theme.of(context).extension<MiniCheckboxThemeData>() ??
        _MiniCheckboxDefaults(context);
  }

  @override
  bool updateShouldNotify(MiniCheckboxTheme oldWidget) =>
      data != oldWidget.data;
}

@immutable
class MiniCheckboxThemeData extends ThemeExtension<MiniCheckboxThemeData> {
  /// Color that used for the border, filling and outside part of checkmark.
  final Color? fillColor;

  /// Color that used for checkmark inside the box.
  final Color? checkColor;

  /// Shape of the checkbox and border.
  final OutlinedBorder? shape;

  /// Border of checkbox when it's unchecked.
  ///
  /// It's use [shape] for shaping.
  final BorderSide? side;

  /// Count of bubbles that shown when checkbox is checked.
  ///
  /// First bubble drawn on the top of checkbox and other goes clockwise.
  final int? bubbleCount;

  /// Colors that will be used for bubbles.
  ///
  /// It's go through full list and start again if there is not enough colors.
  /// So, you can use this to handle some specific case.
  ///
  /// For example, if you want to fill all bubbles with the same color,
  /// then just put list with just this one color.
  final List<Color>? bubbleColors;

  /// Size of checkbox itself. Both width and height.
  final double? size;

  const MiniCheckboxThemeData({
    this.fillColor,
    this.checkColor,
    this.shape,
    this.side,
    this.bubbleCount,
    this.bubbleColors,
    this.size,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiniCheckboxThemeData &&
          runtimeType == other.runtimeType &&
          fillColor == other.fillColor &&
          checkColor == other.checkColor &&
          shape == other.shape &&
          side == other.side &&
          bubbleCount == other.bubbleCount &&
          bubbleColors == other.bubbleColors &&
          size == other.size;

  @override
  int get hashCode => Object.hash(
        fillColor,
        checkColor,
        shape,
        side,
        bubbleCount,
        bubbleColors,
        size,
      );

  @override
  ThemeExtension<MiniCheckboxThemeData> copyWith({
    Color? fillColor,
    Color? checkColor,
    OutlinedBorder? shape,
    BorderSide? side,
    int? bubbleCount,
    List<Color>? bubbleColors,
    double? size,
  }) =>
      MiniCheckboxThemeData(
        fillColor: fillColor ?? this.fillColor,
        checkColor: checkColor ?? this.checkColor,
        shape: shape ?? this.shape,
        side: side ?? this.side,
        bubbleCount: bubbleCount ?? this.bubbleCount,
        bubbleColors: bubbleColors ?? this.bubbleColors,
        size: size ?? this.size,
      );

  @override
  ThemeExtension<MiniCheckboxThemeData> lerp(
    MiniCheckboxThemeData? other,
    double t,
  ) {
    if (other == null) {
      return this;
    }

    final BorderSide? lerpSide;
    if (side != null && other.side != null) {
      lerpSide = BorderSide.lerp(side!, other.side!, t);
    } else {
      lerpSide = null;
    }

    // Maybe should interpolate full list?
    // Like here: https://api.flutter.dev/flutter/dart-ui/Shadow/lerpList.html
    final List<Color>? lerpBubbleColors;
    if (t < 0.5) {
      lerpBubbleColors = bubbleColors;
    } else {
      lerpBubbleColors = other.bubbleColors;
    }

    return MiniCheckboxThemeData(
      fillColor: Color.lerp(fillColor, other.fillColor, t),
      checkColor: Color.lerp(checkColor, other.checkColor, t),
      shape: OutlinedBorder.lerp(shape, other.shape, t),
      side: lerpSide,
      bubbleCount: lerpDouble(bubbleCount, other.bubbleCount, t)?.toInt(),
      bubbleColors: lerpBubbleColors,
      size: lerpDouble(size, other.size, t),
    );
  }
}

class _MiniCheckboxDefaults extends MiniCheckboxThemeData {
  final ThemeData _theme;

  _MiniCheckboxDefaults(BuildContext context) : _theme = Theme.of(context);

  @override
  Color get fillColor => _theme.colorScheme.primary;

  @override
  Color get checkColor => _theme.colorScheme.onPrimary;

  @override
  BorderSide get side => BorderSide(
        width: max(2, size / 12),
        color: fillColor,
      );

  @override
  OutlinedBorder get shape => RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(
            size / 3,
          ),
        ),
      );

  @override
  int get bubbleCount => 6;

  @override
  List<Color> get bubbleColors => const [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.cyan,
        Colors.teal,
      ];

  @override
  double get size => 24;
}
