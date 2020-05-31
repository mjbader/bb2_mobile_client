import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static CupertinoThemeData getCupertinoThemeData() {
    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    return CupertinoThemeData(
        brightness: brightness,
    );
  }

  static ThemeData getLightThemeData() {
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
        )
    );
  }

  static ThemeData getDarkThemeData() {
    return getLightThemeData().copyWith(
//        dividerColor: Colors.white10,
        inputDecorationTheme: InputDecorationTheme(hintStyle: TextStyle(color: Colors.white54)),
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
        )
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

    return isDark ? Colors.black : Colors.white;
  }

  static ThemeData getThemeData() {
    Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    bool isDark = brightness == Brightness.dark;

    return isDark ? getDarkThemeData() : getLightThemeData();
  }
}