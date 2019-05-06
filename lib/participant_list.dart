import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/participant_item.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ParticipantList extends StatefulWidget {
  ParticipantList({Key key, this.compId, this.participants}) : super(key: key);
  final List<XmlElement> participants;
  final String compId;

  @override
  _ParticipantListState createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  List<XmlElement> teamsInvited;
  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void setData(XmlElement compData) {}

  void refreshData() {
    BB2Admin.defaultManager.getSentTickets(widget.compId).then((tickets) {
      setState(() {
        teamsInvited = tickets.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (teamsInvited == null) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Getting Participants...',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(),
            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.display1,
//            ),
          ],
        ),
      );
    } else {
      List<Widget> slivers = List<Widget>();

      if (widget.participants.length == 0 && teamsInvited.length == 0) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'No Participants or Invites',
              ),
            ],
          ),
        );
      }

      if (widget.participants.length > 0) {
        slivers += [
          SliverStickyHeader(
              header: new Container(
                height: 40.0,
                color: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                alignment: Alignment.centerLeft,
                child: new Text(
                  'Participants',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                return ParticipantItem(
                  participant: widget.participants[index],
                );
              }, childCount: widget.participants.length)))
        ];
      }

      if (teamsInvited.length > 0) {
        slivers += [
          SliverStickyHeader(
            header: new Container(
              height: 40.0,
              color: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              alignment: Alignment.centerLeft,
              child: new Text(
                'Invited',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
              return ParticipantItem(
                participant: teamsInvited[index],
              );
            }, childCount: teamsInvited.length)),
          )
        ];
      }

      body = CustomScrollView(shrinkWrap: true, slivers: slivers);
    }

    return Scaffold(
      body: body,
    );
  }
}
