import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bb2_mobile_app/screens/loading.dart';
import 'package:bb2_mobile_app/themes/themes.dart';

import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

void main() async => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

  return Theme(
        data: AppTheme.getThemeData(context),
        child: PlatformApp(
          title: 'ReBBL Admin App',
          home: LoadingScreen(),
          debugShowCheckedModeBanner: false,
          material: (_, platformTarget) => MaterialAppData(
            theme: AppTheme.getLightThemeData(context),
              darkTheme: AppTheme.getDarkThemeData(context),
          ),
          cupertino: (_, platformTarget) => CupertinoAppData(theme: AppTheme.getCupertinoThemeData()),
          localizationsDelegates: [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
        ));
  }
}
