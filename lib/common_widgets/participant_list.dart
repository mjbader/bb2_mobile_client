import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:xml/xml.dart';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/common_widgets/participant_item.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:bb2_mobile_app/themes/themes.dart';

class ParticipantList extends StatefulWidget {
  ParticipantList(
      {Key key, this.compId, this.maxTeams, this.onKick})
      : super(key: key);
  final String compId;
  final int maxTeams;
  final Function onKick;

  @override
  _ParticipantListState createState() => _ParticipantListState();
}

class _ParticipantListState extends State<ParticipantList> {
  List<XmlElement> teamsInvited;
  List<XmlElement> participants;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    BB2Admin.defaultManager.getSentTickets(widget.compId).then((tickets) {
      BB2Admin.defaultManager.getCompetitionData(widget.compId).then((element) {
        setState(() {
          participants = new List<XmlElement>();
          participants = element.findAllElements("CompetitionParticipant").fold(participants,
                  (players, element) {
                var status = int.parse(element.findElements("IdTeamCompetitionStatus").first.text);
                if (status == 1) {
                  players += [element];
                }
                return players;
              });
          teamsInvited = tickets.toList();
        });
      });
    });
  }

  void deleteTicket(XmlElement participant) {
    showPlatformDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return PlatformAlertDialog(
            title: Text('Are you sure delete this ticket?'),
            actions: <Widget>[
              PlatformDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              PlatformDialogAction(
                child: Text('Delete'),
                onPressed: () {
                  var ticketId = participant
                      .findElements("Row")
                      .first
                      .findElements("Id")
                      .first
                      .firstChild
                      .text;
                  setState(() {
                    teamsInvited = null;
                  });
                  BB2Admin.defaultManager.deleteTicket(ticketId).then((value) {
                    participants.remove(participant);
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
                child: Text('Remove'),
                onPressed: () {
                  var teamId = participant
                      .findElements("RowTeam")
                      .first
                      .findElements("ID")
                      .first
                      .firstChild
                      .text;
                  setState(() {
                    teamsInvited = null;
                  });
                  BB2Admin.defaultManager
                      .expelTeamFromComp(widget.compId, teamId)
                      .then((value) {
                    participants.remove(participant);
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

  void forceAcceptDialog(XmlElement participant) {
    showPlatformDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return PlatformAlertDialog(
            title: Text('Are you sure force accept this ticket?'),
            actions: <Widget>[
              PlatformDialogAction(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              PlatformDialogAction(
                child: Text('Accept'),
                onPressed: () => forceAccept(participant),
              ),
            ],
          );
        });
  }

  void forceAccept(XmlElement participant) {
    setState(() {
      teamsInvited = null;
    });

    Navigator.of(context).pop();

    var teamId = participant
        .findElements("RowTeam")
        .first
        .findElements("ID")
        .first
        .firstChild
        .text;
    var ticketId = participant.findElements("Row").first.findElements("Id").first.firstChild.text;
    BB2Admin.defaultManager.getTeamsInfo([teamId]).then((teamInfos) {
      var compRows = teamInfos.first.findAllElements("RowCompetition");

      if (compRows.length > 0) {
        var compId = teamInfos.first.findAllElements("RowCompetition").first.findElements("Id").first.firstChild.text;
        BB2Admin.defaultManager.expelTeamFromComp(compId, teamId).then((result) {
          BB2Admin.defaultManager.acceptTicket(this.widget.compId, teamId, ticketId).then((value) {
            refreshData();
            widget.onKick();
          });
        });
      } else {
        BB2Admin.defaultManager.acceptTicket(this.widget.compId, teamId, ticketId).then((value) {
          refreshData();
          widget.onKick();
        });
      }
    });
  }

  SliverStickyHeader createList(
      {String header,
      List<XmlElement> elements,
      Function deleteFunction,
      Function forceAccept}) {
    return SliverStickyHeader(
        header: new Container(
          height: 40.0,
          color: Theme.of(context).primaryColor,
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
          List<Widget> actions = [
            IconButton(
                icon: Icon(Icons.delete),
                padding: EdgeInsets.only(right: 10),
                color: Colors.red,
                onPressed: () => deleteFunction(elements[index]))
          ];
          var nameElements = elements[index].findAllElements("RowTeam").first.findElements("Name");
          if (forceAccept != null && nameElements.isNotEmpty && nameElements.first.text.toLowerCase().contains("[admin]")) {
            actions += [IconButton(
                icon: Icon(Icons.check),
                padding: EdgeInsets.only(right: 10),
                color: Colors.red,
                onPressed: () => forceAccept(elements[index]))
            ];
          }
          return Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ParticipantItem(
                    participant: elements[index],
                  ),
                  Row(children: actions)
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
                style: Theme.of(context).textTheme.headline6
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: PlatformCircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      List<Widget> slivers = List<Widget>();

      if (participants.length > 0) {
        var numMembers = participants.length;
        slivers += [
          createList(
              header: 'Participants - $numMembers/${widget.maxTeams}',
              elements: participants,
              deleteFunction: removeParticipant),
        ];
      }

      if (teamsInvited.length > 0) {
        var forceAcceptFunction;
        if (participants.length < widget.maxTeams) {
          forceAcceptFunction = forceAcceptDialog;
        }

        slivers += [
          createList(
              header: 'Invited',
              elements: teamsInvited,
              deleteFunction: deleteTicket,
              forceAccept: forceAcceptFunction),
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
      backgroundColor: AppTheme.getBackgroundColor(),
      body: body,
    );
  }
}
