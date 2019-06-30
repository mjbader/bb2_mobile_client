import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/leagues.dart';
import 'package:bb2_mobile_app/login.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    var userFuture = FlutterKeychain.get(key: "bb2username");
    var passwordFuture = FlutterKeychain.get(key: "bb2password");
    var prefsFuture = SharedPreferences.getInstance();
    Future.wait([userFuture, passwordFuture, prefsFuture]).then((List<dynamic> values) {
      String username = values[0];
      String password = values[1];
      SharedPreferences prefs = values[2];

      try {
        var autologin = prefs.getBool("autologin");
        if (!autologin) {
          navigateToLogin();
          return;
        }
      } catch(error) {
        navigateToLogin();
        return;
      }

      if (username == null || password == null) {
        navigateToLogin();
        return;
      }

      if (username.isNotEmpty && password.isNotEmpty) {
        BB2Admin.defaultManager.connect(username,password).then((result) {
          Navigator.pushReplacement(context, platformPageRoute(builder: (context) => LeagueScreen()));
        }, onError: (error) {
          navigateToLogin();
        });
      } else {
        navigateToLogin();
      }
    }, onError: (error) {
      navigateToLogin();
    });

  }

  void navigateToLogin() {
    Navigator.pushReplacement(context, platformPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: PlatformCircularProgressIndicator()
      )
    );
  }
}