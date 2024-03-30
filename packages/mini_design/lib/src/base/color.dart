import 'dart:ui';

/// See https://stackoverflow.com/a/60191441
Color darkenColor(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  final f = 1 - percent / 100;
  return Color.fromARGB(
    c.alpha,
    (c.red * f).round(),
    (c.green * f).round(),
    (c.blue * f).round(),
  );
}

/// See https://stackoverflow.com/a/60191441
Color lightenColor(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  final p = percent / 100;
  return Color.fromARGB(
    c.alpha,
    c.red + ((255 - c.red) * p).round(),
    c.green + ((255 - c.green) * p).round(),
    c.blue + ((255 - c.blue) * p).round(),
  );
}

/// [ratio] must be from -1.0 to 1.0
/// when ratio = 0, then both from & to must have 100 percents
/// when ratio = 1, then from must have 200 percents, and to have 0
/// when ratio = -1, then from must have 0 percents, and to have 200
Color between(
  Color from,
  Color to, [
  double ratio = 0,
]) {
  final fromP = 1.0 - ratio;
  final toP = (-1 - ratio).abs();

  return Color.fromARGB(
    (from.alpha * fromP + to.alpha * toP) ~/ 2,
    (from.red * fromP + to.red * toP) ~/ 2,
    (from.green * fromP + to.green * toP) ~/ 2,
    (from.blue * fromP + to.blue * toP) ~/ 2,
  );
}

extension ColorUtils on Color {
  Color darken([int percent = 10]) => darkenColor(this, percent);

  Color lighten([int percent = 10]) => lightenColor(this, percent);
}
