import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:bb2_mobile_app/themes/themes.dart';

class NumberPicker extends StatefulWidget {
  const NumberPicker({Key key,
    this.onChanged,
    this.value,
    this.min = 1,
    this.max,
    this.label
  }) : super(key: key);

  @override
  State createState() => _NumberPickerState();

  final ValueChanged<int> onChanged;
  final int value;
  final int min;
  final int max;
  final String label;
}

class _NumberPickerState extends State<NumberPicker> {
  void valueChanged(int value) {
    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    Function minusFunc;
    Color minusColor = AppTheme.getTextColor();;
    Function plusFunc;
    Color plusColor = AppTheme.getTextColor();
    if (widget.value > widget.min) {
      minusFunc = () => valueChanged(widget.value - 1);
    } else {
      minusColor = Colors.grey;
    }

    if (widget.max == null || widget.value < widget.max) {
      plusFunc  = () => valueChanged(widget.value + 1);
    } else {
      plusColor = Colors.grey;
    }

    return Column(
        children: <Widget>[
    if (this.widget.label != null)
    Text(this.widget.label), Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        margin: const EdgeInsets.all(0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(30)
        ),
        child: Row(
        mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            RawMaterialButton(
                constraints: BoxConstraints(),
                padding: const EdgeInsets.all(0),
                child: Icon(Icons.remove, color: minusColor),
                onPressed: minusFunc,
                shape: CircleBorder(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
            Container(
                padding: const EdgeInsets.all(0),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: PlatformText(widget.value.toString(),
                    style: TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold))),
            RawMaterialButton(
                constraints: BoxConstraints(),
                padding: const EdgeInsets.all(0),
                child: Icon(Icons.add, color: plusColor),
                onPressed: plusFunc,
                shape: CircleBorder(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)
          ],
        )
    )]);
  }
}
