import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'dart:io';

import 'cross_platform_widgets/cptextfield.dart';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/leagues.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _username = "";
  String _password = "";
  bool _isLoading = false;
  bool _rememberMe = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _whiteList = [
    'rebbl',
    'fullmetalcos',
    'miraskadu',
    'luminous',
    'bleedinghippy',
    'isenmike',
    'kejiruze',
    'majorbyte',
    'rumblebee',
    'schlice',
    'munkey chunks',
    'morka',
    'cakengrad',
    'superfedtv',
    'spicasaurus',
    'gerbear',
    'tomast',
    'mmcnaughton4',
    'mystaes',
    'holes',
    'kallisti maya',
    'hindi',
    'archxl',
    'zeazetta',
    'gypsy prince',
    'chubstep_',
    'he roto su cara',
    'one30',
    '#420nochin',
    'shadorra',
    'docmarc',
    'hummersepp',
    'rusty seabutter',
    'tommo',
    'krusader',
    'liamcoulston',
    'lyskaris',
    'hindi',
    'lumibot',
    'lumiboto',
    'larkstar',
    'meshuggah',
    'seanmantv',
    'steakmittens',
    'harringzord'
  ];

  void showError(String error) {
    if (Platform.isAndroid) {
      _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: new Text(error),
      ));
    } else {
      showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          title: Text('Error'),
          content: Text(error),
          actions: <Widget>[
            PlatformDialogAction(child: Text('OK'), onPressed: () => Navigator.of(context).pop(),),
          ],
        ),
      );
    }
  }

  void loginPressed() async {
    if (!_whiteList.contains(_username.toLowerCase())) {
      showError("User has no rebbl access");
      return;
    }

    setState(() {
      _isLoading = true;
    });
    BB2Admin.defaultManager.connect(_username,_password).then((result) {
      if (_rememberMe) {
        FlutterKeychain.put(key: "bb2username", value: _username);
        FlutterKeychain.put(key: "bb2password", value: _password);
        SharedPreferences.getInstance().then((prefs) => prefs.setBool("autologin", true));
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LeagueScreen()));
    }, onError: (error) {
      setState(() {
        _isLoading = false;
        showError(error.toString());
      });
    });
  }

  bool isLoginButtonEnabled() {
    return _username.isNotEmpty && _password.isNotEmpty && !_isLoading;
  }

  @override
  Widget build(BuildContext context) {

    Widget button =  Builder(
        builder: (context) => PlatformButton(
      child: Text('Login'),
      onPressed: isLoginButtonEnabled() ? () => loginPressed() : null,
      )
    );

    if (_isLoading) {
      button = PlatformCircularProgressIndicator();
    }

    return PlatformScaffold(
      backgroundColor: Colors.red,
      widgetKey: _scaffoldKey,
      body: Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                color: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset("assets/rebbl_logo.png",
                      width: 100.0,
                      height: 100.0,
                    ),
                    Text("Admin Client Alpha",
                      style: TextStyle(fontSize: 20),
                    ),
                    CPTextField(
                      placeholder: 'Username',
                      onChanged: (username) => setState(() {
                        _username = username;
                      }),
                    ),
                    CPTextField(
                      obscureText: true,
                      placeholder:'Password',
                      onChanged: (password) => setState(() {
                        _password = password;
                      }),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text('Remember Me  '),
                    PlatformSwitch(
                      value: _rememberMe,
                      onChanged: (value) => setState(() {
                        _rememberMe = value;
                      }),),],),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: button
                      ,)
                  ],
                )
            ),
          )
          )
      ),
    );
  }
}