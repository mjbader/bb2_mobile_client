import 'package:bb2_mobile_app/themes/themes.dart';
import 'package:flutter/material.dart';

class CPTextField extends StatelessWidget {
  final String? placeholder;
  final Function(String)? onChanged;
  final bool? obscureText;

  CPTextField({Key? key, this.placeholder, this.onChanged, this.obscureText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textField = TextField(
      onChanged: onChanged,
      obscureText: obscureText ?? false,
      style: TextStyle(color: AppTheme.getTextColor()),
      decoration: InputDecoration(
        labelText: placeholder,
        labelStyle: TextStyle(color: AppTheme.getTextColor()),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.getTextColor(), width: 1.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
      ),
    );

    return textField;
  }
}
