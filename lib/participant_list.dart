import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:BB2Admin/bb2admin.dart';

import 'package:bb2_mobile_app/participant_item.dart';

class ParticipantList extends StatefulWidget {
  ParticipantList({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ParticipantListState createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {

  @override void initState() {
    super.initState();
    refreshData();
  }


  void setData(XmlElement compData) {

  }

  void refreshData() {

  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
          )
        ],
      ),
      body: body,
    );
  }
}
