import 'package:flutter/material.dart';
import 'package:bb2_mobile_app/screens/loading.dart';
import 'package:bb2_mobile_app/themes/themes.dart';

void main() async => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

  return Theme(
        data: AppTheme.getThemeData(context),
        child: MaterialApp(
          title: 'ReBBL Admin App',
          home: LoadingScreen(),
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getLightThemeData(context),
          darkTheme: AppTheme.getDarkThemeData(context),
          localizationsDelegates: [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
        ));
  }
}
