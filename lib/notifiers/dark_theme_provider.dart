import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DarkThemeProvider with ChangeNotifier {
  bool _darkTheme = false;

  bool get darkTheme => _darkTheme;

  set darkTheme(bool value) {
    _darkTheme = value;
    SharedPreferences.getInstance().then((prefs) => {
      prefs.setBool("DARKMODE", value)
    });
    notifyListeners();
  }
}