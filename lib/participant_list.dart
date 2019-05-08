import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/participant_item.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ParticipantList extends StatefulWidget {
  ParticipantList({Key key, this.compId, this.participants, this.maxTeams}) : super(key: key);
  final List<XmlElement> participants;
  final String compId;
  final int maxTeams;

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

  void refreshData() {
    BB2Admin.defaultManager.getSentTickets(widget.compId).then((tickets) {
      setState(() {
        teamsInvited = tickets.toList();
      });
    });
  }

  SliverStickyHeader createList({String header, List<XmlElement> elements}) {
    return SliverStickyHeader(
        header: new Container(
          height: 40.0,
          color: Colors.red,
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.centerLeft,
          child: new Text(
            header,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
        sliver: SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
          return Column(
            children: <Widget>[
              ParticipantItem(
                participant: elements[index],
              ),
              Divider()
            ],
          );
        }, childCount: elements.length)));
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
          ],
        ),
      );
    } else {
      List<Widget> slivers = List<Widget>();

      if (widget.participants.length > 0) {
        var numMembers = widget.participants.length;
        slivers += [
          createList(header: 'Participants - $numMembers/${widget.maxTeams}', elements: widget.participants),
        ];
      }

      if (teamsInvited.length > 0) {
        slivers += [
          createList(header: 'Invited', elements: teamsInvited),
        ];
      }

      if (slivers.isEmpty) {
        body = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'No Participants or Invites',
              ),
            ],
          ),
        );
      } else {
        body = CustomScrollView(shrinkWrap: true, slivers: slivers);
      }
    }

    return Scaffold(
      body: body,
    );
  }
}
