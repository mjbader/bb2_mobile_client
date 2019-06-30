import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

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
      ios: (context) => CupertinoTextFieldData(
          placeholder: placeholder,
          placeholderStyle: TextStyle(
              fontWeight: FontWeight.w300, color: Color(0xFFC2C2C2))),
      android: (context) => MaterialTextFieldData(
        decoration: InputDecoration(labelText: placeholder),
      ),
    );

    return Padding(padding: EdgeInsets.all((Platform.isIOS ? 6 : 0)), child: textField,);
  }
}
