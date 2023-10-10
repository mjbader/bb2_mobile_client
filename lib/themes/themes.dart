import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData getLightThemeData(BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.red,
      brightness: Brightness.light,
      dividerTheme: DividerThemeData(space: 0),
      inputDecorationTheme:
          InputDecorationTheme(hintStyle: TextStyle(color: Colors.black54)),
      textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.w400, color: Colors.black),
          titleMedium: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              letterSpacing: 0.15),
          titleSmall: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
              letterSpacing: 0.1)),
      buttonTheme: Theme.of(context)
          .buttonTheme
          .copyWith(colorScheme: ColorScheme.light()),
    );
  }

  static ThemeData getDarkThemeData(BuildContext context) {
    return getLightThemeData(context).copyWith(
      unselectedWidgetColor: Colors.white,
      brightness: Brightness.dark,
      dividerColor: Colors.white10,
      inputDecorationTheme:
          InputDecorationTheme(hintStyle: TextStyle(color: Colors.white54)),
      scaffoldBackgroundColor: getBackgroundColor(context),
      textTheme: TextTheme(
          titleLarge: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.15,
              color: Colors.white),
          titleMedium: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
              letterSpacing: 0.15),
          titleSmall: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w400,
              color: Colors.white54,
              letterSpacing: 0.1)),
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
            colorScheme: ColorScheme.dark(),
            buttonColor: Color(0xff3B3B3B),
          ),
      iconTheme: IconThemeData(color: Colors.white),
      disabledColor: Colors.white24,
      textButtonTheme: TextButtonThemeData(style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) {
          return Colors.white24;
        } else {
          return Colors.white;
        }
      }))),
      appBarTheme: AppBarTheme(
        elevation: 0.0,
        titleTextStyle: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
            color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
        color: Color(0xFF1A1A1A),
      ),
    );
  }

  static Color getTextColor() {
    Brightness? brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? Colors.white : Colors.black;
  }

  static Color getLoginBackgroundColor() {
    Brightness? brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? Color(0xFF121212) : Colors.red;
  }

  static Color getLoginForegroundColor() {
    Brightness? brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? Colors.white24 : Colors.white;
  }

  static Color getBackgroundColor(BuildContext context) {
    Brightness? brightness = MediaQuery.of(context).platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? Color(0xFF121212) : Colors.white;
  }

  static Color getAlertBackgroundcolor() {
    Brightness? brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? Color(0xFF171717) : Colors.white;
  }

  static ThemeData getThemeData(BuildContext context) {
    Brightness? brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? getDarkThemeData(context) : getLightThemeData(context);
  }
}
