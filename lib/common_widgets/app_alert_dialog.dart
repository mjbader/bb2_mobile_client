import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/widgets.dart';
import 'package:bb2_mobile_app/themes/themes.dart';



//final Key widgetKey;
//final List<Widget> actions;
//final Widget content;
//final Widget title;
//final PlatformBuilder<MaterialAlertDialogData> android;
//final PlatformBuilder<CupertinoAlertDialogData> ios;
class AppAlertDialog extends PlatformAlertDialog {
  AppAlertDialog(
      {Key? key,
        Key? widgetKey,
        List<Widget>? actions,
        Widget? content,
        Widget? title,
        PlatformBuilder<MaterialAlertDialogData>? android,
        PlatformBuilder<CupertinoAlertDialogData>? cupertino})
      : super(key: key,
      widgetKey: widgetKey,
      actions: actions,
      content: content,
      title: title,
      cupertino: cupertino,
    material: (context, platformTarget) => MaterialAlertDialogData(
      backgroundColor: AppTheme.getAlertBackgroundcolor(),
    ),);
}