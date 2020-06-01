import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static CupertinoThemeData getCupertinoThemeData() {
    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    return CupertinoThemeData(
      scaffoldBackgroundColor: getBackgroundColor(),
        brightness: brightness,
    );
  }

  static ThemeData getLightThemeData(BuildContext context) {
    return ThemeData(
        primarySwatch: Colors.red,
        inputDecorationTheme: InputDecorationTheme(hintStyle: TextStyle(color: Colors.black54)),
        textTheme: TextTheme(
            headline6: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                color: Colors.black
            ),
            subtitle1: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                letterSpacing: 0.15
            ),
            subtitle2: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                letterSpacing: 0.1
            )
        ),
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: ColorScheme.light()),
    );
  }

  static ThemeData getDarkThemeData(BuildContext context) {
    return getLightThemeData(context).copyWith(
      brightness: Brightness.dark,
//        dividerColor: Colors.white10,
        inputDecorationTheme: InputDecorationTheme(hintStyle: TextStyle(color: Colors.white54)),
      scaffoldBackgroundColor: getBackgroundColor(),
        primaryColor: getLightThemeData(context).primaryColor.withAlpha(190),
        textTheme: TextTheme(
            headline6: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.15,
                color: Colors.white
            ),
            subtitle1: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
                letterSpacing: 0.15
            ),
            subtitle2: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                color: Colors.white54,
                letterSpacing: 0.1
            )
        ),
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: ColorScheme.dark(), buttonColor: Color(0xff3B3B3B)),
    );
  }

  static Color getTextColor() {
    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? Colors.white : Colors.black;
  }

  static Color getBackgroundColor() {

    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? Color(0xFF121212) : Colors.white;
  }

  static Color getAlertBackgroundcolor() {
    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? Color(0xFF171717) : Colors.white;
  }

  static ThemeData getThemeData(BuildContext context) {
    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? getDarkThemeData(context) : getLightThemeData(context);
  }
}