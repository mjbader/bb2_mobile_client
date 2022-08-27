
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {

  ListItem({this.isEditable, required this.isSelected, required this.onChanged, required this.child}) : super();

  final bool? isEditable;
  final bool isSelected;
  final Function(bool?) onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isEditable ?? false) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Checkbox(
            value: isSelected,
            onChanged: onChanged,
          ),
          Expanded(child: child)
        ],
      );
    } else {
      return child;
    }
  }
}