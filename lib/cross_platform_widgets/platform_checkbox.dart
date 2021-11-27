import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:io';
import 'dart:math' as math;

class PlatformCheckbox extends StatefulWidget {

  const PlatformCheckbox({
    Key key,
    @required this.value,
    this.tristate = false,
    @required this.onChanged,
    this.activeColor,
    this.checkColor,
  }) : super(key: key);

  final bool value;
  final bool tristate;
  final Color activeColor;
  final Color checkColor;
  final ValueChanged<bool> onChanged;
  static const width = 20.0;

  @override
  _PlatformCheckboxState createState() => _PlatformCheckboxState();
}

class _PlatformCheckboxState extends State<PlatformCheckbox> with TickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      tristate: widget.tristate,
      value: widget.value,
      activeColor: widget.activeColor,
      checkColor: widget.checkColor,
      onChanged: widget.onChanged,
    );
  }
}