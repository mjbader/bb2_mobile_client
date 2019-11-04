import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:xml/xml.dart';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/participant_item.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

class ParticipantList extends StatefulWidget {
  ParticipantList({Key key, this.compId, this.participants, this.maxTeams, this.onKick}) : super(key: key);
  final List<XmlElement> participants;
  final String compId;
  final int maxTeams;
  final Function onKick;

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

  void removeParticipant(XmlElement participant) {
    showPlatformDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return PlatformAlertDialog(
            title: Text('Are you sure remove this participant?'),
            actions: <Widget>[
              PlatformDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              PlatformDialogAction(
                child: Text('Yes'),
                onPressed: () {
                  var teamId = participant.findElements("RowTeam").first.findElements("ID").first.firstChild.text;
                  setState(() {
                    teamsInvited = null;
                  });
                  BB2Admin.defaultManager.expelTeamFromComp(widget.compId, teamId).then((value) {
                    widget.participants.remove(participant);
                    widget.onKick();
                    refreshData();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
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
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        sliver: SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ParticipantItem(
                    participant: elements[index],
                  ),
                  IconButton(
                    icon: Icon(Icons.block),
                    padding: EdgeInsets.only(right: 10),
                    color: Colors.red,
                    onPressed: () => removeParticipant(elements[index])
                  )
                ],
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
