import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const iconOrangeColor = Color(0xFFFF9800);
const iconBlueColor = Color(0xFF03A9F4);

const _iosBackgroundPrimaryLight = Color(0xFFFFFFFF);
const _iosBackgroundPrimaryDark = Color(0xFF1C1C1E);

const _iosBackgroundSecondaryLight = Color(0xFFF2F2F7);
const _iosBackgroundSecondaryDark = Color(0xFF000000);

const _iosDividerLight = Color(0xffc6c6c8);
const _iosDividerDark = Color(0xff38383a);

const _iosLabelPrimaryLight = Color(0xff000000);
const _iosLabelPrimaryDark = Color(0xFFFFFFFF);

const _iosLabelSecondaryLight = Color(0x993C3C43);
const _iosLabelSecondaryDark = Color(0x99EBEBF5);

const _iosErrorLight = Color(0xFFFF3B30);
const _iosErrorDark = Color(0xFFFF453A);

extension BrightnessUtils on Brightness {
  Brightness get reverse {
    switch (this) {
      case Brightness.dark:
        return Brightness.light;
      case Brightness.light:
        return Brightness.dark;
    }
  }
}

ThemeData miniThemeFactory({
  required Brightness brightness,
  required Color primaryColor,
}) {
  final isDark = brightness == Brightness.dark;

  final colorScheme = generateColorScheme(
    primary: primaryColor,
    brightness: brightness,
  );

  final appBarColor = colorScheme.background;
  final appBarBrightness = ThemeData.estimateBrightnessForColor(appBarColor);

  final InteractiveInkFeatureFactory splashFactory;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      splashFactory = NoSplash.splashFactory;
      break;
    // ignore: no_default_cases
    default:
      splashFactory = InkRipple.splashFactory;
      break;
  }

  final textTheme = generateTextTheme(brightness: brightness);

  return ThemeData(
    brightness: brightness,
    splashFactory: splashFactory,
    colorScheme: colorScheme,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: appBarColor,
      foregroundColor:
          appBarBrightness == Brightness.dark ? Colors.white : Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: appBarBrightness.reverse,
        statusBarBrightness: appBarBrightness,
      ),
      centerTitle: true,
      titleTextStyle: textTheme.body?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 3,
      highlightElevation: 0,
      backgroundColor: colorScheme.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12))),
      checkColor: MaterialStateProperty.all(colorScheme.onPrimary),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark ? Colors.grey.shade100 : Colors.grey.shade900,
      actionTextColor: isDark ? Colors.indigo : Colors.orange,
      contentTextStyle: TextStyle(color: isDark ? Colors.black : Colors.white),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SharedAxisPageTransitionsBuilder(
          transitionType: SharedAxisTransitionType.horizontal,
          fillColor: colorScheme.background,
        ),
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
      },
    ),
    scaffoldBackgroundColor: colorScheme.background,
    dividerColor: isDark ? _iosDividerDark : _iosDividerLight,
    dialogTheme: const DialogTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
      ),
    ),
    primaryColor: Colors.blue,
    dialogBackgroundColor: colorScheme.background,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      hintStyle: TextStyle(
        color: isDark ? _iosLabelSecondaryDark : _iosLabelSecondaryLight,
      ),
    ),
    extensions: {
      MiniColorScheme(
        todayHighlightColor:
            isDark ? Colors.green.shade500 : Colors.green.shade700,
      ),
    },
  );
}

ColorScheme generateColorScheme({
  required Color primary,
  required Brightness brightness,
}) {
  final isDark = brightness == Brightness.dark;
  final primaryIsDark =
      ThemeData.estimateBrightnessForColor(primary) == Brightness.dark;
  final secondary = primary;
  final secondaryIsDark =
      ThemeData.estimateBrightnessForColor(secondary) == Brightness.dark;

  return ColorScheme(
    primary: primary,
    primaryContainer:
        isDark ? _iosBackgroundPrimaryDark : _iosBackgroundPrimaryLight,
    secondary: secondary,
    surface:
        isDark ? _iosBackgroundSecondaryDark : _iosBackgroundSecondaryLight,
    background: isDark ? _iosBackgroundPrimaryDark : _iosBackgroundPrimaryLight,
    error: isDark ? _iosErrorDark : _iosErrorLight,
    onPrimary: primaryIsDark ? _iosLabelPrimaryDark : _iosLabelPrimaryLight,
    onSecondary: secondaryIsDark ? _iosLabelPrimaryDark : _iosLabelPrimaryLight,
    onSurface: isDark ? _iosLabelPrimaryDark : _iosLabelPrimaryLight,
    onBackground: isDark ? _iosLabelPrimaryDark : _iosLabelPrimaryLight,
    onError: isDark ? _iosLabelPrimaryLight : _iosLabelPrimaryDark,
    brightness: brightness,
  );
}

TextTheme generateTextTheme({
  required Brightness brightness,
}) {
  final isDark = brightness == Brightness.dark;
  final primaryColor = isDark ? _iosLabelPrimaryDark : _iosLabelPrimaryLight;
  final secondaryColor =
      isDark ? _iosLabelSecondaryDark : _iosLabelSecondaryLight;

  // Use for both titleMedium and bodyLarge
  // Because we need to use them in all this cases:
  // - App bar
  // - Body text
  // - Text Fields
  final bodyStyle = TextStyle(
    fontSize: 17,
    color: primaryColor,
    letterSpacing: -0.4,
    fontWeight: FontWeight.normal,
  );

  return TextTheme(
    headlineMedium: TextStyle(
      fontSize: 34,
      color: primaryColor,
      letterSpacing: -0.4,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      color: primaryColor,
      letterSpacing: -0.4,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: bodyStyle,
    bodyLarge: bodyStyle,
    bodySmall: TextStyle(
      fontSize: 15,
      color: secondaryColor,
      letterSpacing: -0.4,
      fontWeight: FontWeight.w500,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      color: secondaryColor,
      letterSpacing: -0.4,
      fontWeight: FontWeight.w500,
    ),
  );
}

@immutable
class MiniColorScheme extends ThemeExtension<MiniColorScheme> {
  /// Color that used on date(time) fields when date is today and time is not overdue.
  final Color todayHighlightColor;

  const MiniColorScheme({
    required this.todayHighlightColor,
  });

  @override
  ThemeExtension<MiniColorScheme> copyWith({
    Color? todayHighlightColor,
  }) =>
      MiniColorScheme(
        todayHighlightColor: todayHighlightColor ?? this.todayHighlightColor,
      );

  @override
  ThemeExtension<MiniColorScheme> lerp(MiniColorScheme? other, double t) {
    if (other == null) {
      return this;
    }

    return MiniColorScheme(
      todayHighlightColor: Color.lerp(
            todayHighlightColor,
            other.todayHighlightColor,
            t,
          ) ??
          other.todayHighlightColor,
    );
  }
}

extension MiniColorSchemeTheme on ThemeData {
  MiniColorScheme get miniColorScheme => extension<MiniColorScheme>()!;
}

/// Our mapping to the right [TextStyle]
///
/// We use about 5 our text styles, that is base of our typography.
/// So, to be consistent through the app – use our implementation.
extension MiniTextTheme on TextTheme {
  TextStyle? get headline => headlineMedium;

  TextStyle? get title => titleLarge;

  TextStyle? get body => bodyLarge;

  TextStyle? get subtitle => bodySmall;

  TextStyle? get label => labelMedium;
}

extension MiniTheme on ThemeData {
  Color get backgroundPrimary => colorScheme.background;

  Color get backgroundSecondary => colorScheme.surface;
}
