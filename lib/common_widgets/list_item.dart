
import 'package:flutter/widgets.dart';
import 'package:bb2_mobile_app/cross_platform_widgets/platform_checkbox.dart';


class ListItem extends StatelessWidget {

  ListItem({this.isEditable, this.isSelected, this.onChanged, this.child}) : super();

  final bool isEditable;
  final bool isSelected;
  final Function onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isEditable) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          PlatformCheckbox(
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