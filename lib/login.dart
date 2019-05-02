import 'package:flutter/material.dart';
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

  void loginPressed() async {
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
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
          content: new Text(error.toString()),
        ));
      });
    });
  }

  bool isLoginButtonEnabled() {
    return _username.isNotEmpty && _password.isNotEmpty && !_isLoading;
  }

  @override
  Widget build(BuildContext context) {

    Widget button =  Builder(
        builder: (context) => RaisedButton(
      child: Text('Login'),
      onPressed: isLoginButtonEnabled() ? () => loginPressed() : null,
      )
    );

    if (_isLoading) {
      button = CircularProgressIndicator();
    }

    return Scaffold(
      backgroundColor: Colors.red,
      key: _scaffoldKey,
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
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Username'
                      ),
                      onChanged: (username) => setState(() {
                        _username = username;
                      }),
                    ),
                    TextField(
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'Password'
                      ),
                      onChanged: (password) => setState(() {
                        _password = password;
                      }),
                    ),
                    CheckboxListTile(
                      title: Text('Remember Me'),
                      value: _rememberMe,
                      onChanged: (value) => setState(() {
                        _rememberMe = value;
                      }),),
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