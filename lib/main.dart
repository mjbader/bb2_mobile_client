import 'package:flutter/material.dart';
import 'package:bb2_mobile_app/loading.dart';

import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void main() async => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return PlatformApp(
        title: 'ReBBL Admin App',
        home: LoadingScreen(),
        android: (_) => MaterialAppData(
              theme: ThemeData(
                primarySwatch: Colors.red,
              ),
            ),
        ios: (_) => CupertinoAppData()
    );
  }
}
