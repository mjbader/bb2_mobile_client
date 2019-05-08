import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'types.dart';

class MatchItem extends StatelessWidget {
  final XmlElement matchElement;
  final HashMap<String, XmlElement> participants;

  const MatchItem({Key key, this.matchElement, this.participants}) : super(key:key);

  void _matchSelected(int status, BuildContext context, Widget match) async {
//    if (true) {//(status == MatchStatus.unvalidated) {
//      switch (await showDialog<String>(
//          context: context,
//          builder: (BuildContext context) {
//            return SimpleDialog(
//              title: const Text('Admin Match Options'),
//              children: <Widget>[
//                SimpleDialogOption(
//                  onPressed: () { Navigator.pop(context, "naha"); },
//                  child: Row(children: <Widget>[Icon(Icons.check), Text('  Validate', style: TextStyle(fontSize: 20))],),
//                ),
//                SimpleDialogOption(
//                  onPressed: () { Navigator.pop(context, "baha"); },
//                  child: Row(children: <Widget>[Icon(Icons.cancel), Text('  Reset', style: TextStyle(fontSize: 20))],),
//                ),
//              ],
//            );
//          }
//      )) {
//        case "naha":
//          showDialog(context: context, builder: (BuildContext context) {
//            return AlertDialog(title: Text("Are you sure wish to validate this match?"),
//              content: SingleChildScrollView(child: match),
//              actions: <Widget>[
//              FlatButton(
//                child: Text('Cancel'),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              ),
//              FlatButton(
//                child: Text('Yes'),
//                onPressed: () {
//                  Navigator.of(context).pop();
//                },
//              ),
//            ],);
//          });
//          break;
//        case "baha":
//          showDialog(context: context, builder: (BuildContext context) {
//            return AlertDialog(title: Text("Are you sure wish to reset this match?"),
//              content: SingleChildScrollView(child: match),
//              actions: <Widget>[
//                FlatButton(
//                  child: Text('Cancel'),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                  },
//                ),
//                FlatButton(
//                  child: Text('Yes'),
//                  onPressed: () {
//                    Navigator.of(context).pop();
//                  },
//                ),
//              ],);
//          });
//          break;
//      }
//    }
  }

  @override
  Widget build(BuildContext context) {
    var status = int.parse(matchElement.findElements("IdStatus").first.text);
    var homeScore = matchElement.findElements("HomeScore").first.text;
    var homeTeamId = matchElement.findElements("IdTeamHome").first.children.first.text;
    var homeTeam = participants[homeTeamId];
    var homeTeamName;
    if (homeTeam == null) {
      homeTeamName = "Loading...";
    } else {
      homeTeamName = participants[homeTeamId].findAllElements("Name").first.text;
    }

    var awayScore = matchElement.findElements("AwayScore").first.text;
    var awayTeamId = matchElement.findElements("IdTeamAway").first.children.first.text;
    var awayTeam = participants[awayTeamId];
    var awayTeamName;
    if (awayTeam == null) {
      awayTeamName = "Loading...";
    } else {
      awayTeamName = participants[awayTeamId].findAllElements("Name").first.text;
    }

    Function onPressed;

    if (status == MatchStatus.unplayed) {
      homeScore = '?';
      awayScore = '?';
    }

    var scoreColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$homeScore', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
          Text('$awayScore', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
        ]);

    var teamColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$homeTeamName', style: TextStyle(fontSize: 20.0)),
          Text('$awayTeamName', style: TextStyle(fontSize: 20.0)),
        ]);

    var child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            teamColumn,
            scoreColumn,
          ]),
    );

    if (status != MatchStatus.validated) {
      onPressed = () => _matchSelected(status, context, teamColumn);
    }

    return FlatButton(child: child, onPressed: onPressed,);
  }
}