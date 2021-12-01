import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/screens/leagues.dart';
import 'package:bb2_mobile_app/screens/login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  LoadingScreen({Key? key}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    final storage = FlutterSecureStorage();
    var userFuture = storage.read(key: "bb2username");
    var passwordFuture = storage.read(key: "bb2password");
    var prefsFuture = SharedPreferences.getInstance();
    Future.wait([userFuture, passwordFuture, prefsFuture]).then((List<dynamic> values) {
      String username = values[0];
      String password = values[1];
      SharedPreferences prefs = values[2];

      try {
        var autologin = prefs.getBool("autologin") ?? false;
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
        BB2Admin.defaultManager.connect(username: username,password: password).then((result) {
          Navigator.pushReplacement(context, platformPageRoute(context: context, builder: (context) => LeagueScreen()));
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
    Navigator.pushReplacement(context, platformPageRoute(context: context, builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Center(
          child: PlatformCircularProgressIndicator()
      )
    );
  }
}