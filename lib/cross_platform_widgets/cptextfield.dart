import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:bb2_mobile_app/themes/themes.dart';

class CPTextField extends StatelessWidget {
  final String placeholder;
  final Function onChanged;
  final bool obscureText;

  CPTextField({Key key, this.placeholder, this.onChanged, this.obscureText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    var textField = PlatformTextField(
      onChanged: onChanged,
      obscureText: obscureText ?? false,
      cupertino: (context, platformTarget) => CupertinoTextFieldData(
          placeholder: placeholder,
          placeholderStyle: TextStyle(
              fontWeight: FontWeight.w300, color: Color(0xFFC2C2C2))),
      material: (context, platformTarget) => MaterialTextFieldData(
        style: TextStyle(color: AppTheme.getTextColor()),
        decoration: InputDecoration(labelText: placeholder,
          labelStyle: TextStyle(color: AppTheme.getTextColor()),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: AppTheme.getTextColor(), width: 1.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Colors.red, width: 1.0),
          ),
        ),
      ),
    );

    return Padding(padding: EdgeInsets.all((Platform.isIOS ? 6 : 0)), child: textField,);
  }
}
