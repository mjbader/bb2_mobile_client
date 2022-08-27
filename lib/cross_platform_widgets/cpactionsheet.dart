import 'package:flutter/material.dart';
import 'package:bb2_mobile_app/themes/themes.dart';


Future<T?> showPlatformActionSheet<T>(
    {required BuildContext context,
    required List<PlatformActionSheetAction<T>> children,
    required String title}) {
    var actions = children.map((action) {
      return SimpleDialogOption(
        onPressed: () => Navigator.pop(context, action.result),
        child: action.widget,
      );
    }).toList();
    return showDialog<T>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text(title), children: actions, backgroundColor: AppTheme.getAlertBackgroundcolor(),);
        });
}

class PlatformActionSheetAction<T> {
  final Widget widget;
  final T result;

  PlatformActionSheetAction({required this.widget, required this.result});
}
