import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'types.dart';

class MatchItem extends StatelessWidget {
  final XmlElement matchElement;
  final HashMap<String, XmlElement> participants;

  const MatchItem({Key key, this.matchElement, this.participants}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    var status = int.parse(matchElement.findElements("IdStatus").first.text);
    var homeScore = matchElement.findElements("HomeScore").first.text;
    var homeTeamId = matchElement.findElements("IdTeamHome").first.firstChild.text;
    var homeTeam = participants[homeTeamId];
    var homeTeamName = "Loading...";
    var homeCoachName = "Loading...";
    if (homeTeam != null) {
      homeTeamName = homeTeam.findAllElements("Name").first.text;
      if (homeTeam.findElements("NameCoach").isNotEmpty) {
        homeCoachName = homeTeam.findElements("NameCoach").first.text;
      } else {
        homeCoachName = "AI";
      }
    }

    var awayScore = matchElement.findElements("AwayScore").first.text;
    var awayTeamId = matchElement.findElements("IdTeamAway").first.firstChild.text;
    var awayTeam = participants[awayTeamId];
    var awayTeamName = "Loading...";
    var awayCoachName = "Loading...";
    if (awayTeam != null) {
      awayTeamName = awayTeam.findAllElements("Name").first.text;
      if (awayTeam.findElements("NameCoach").isNotEmpty) {
        awayCoachName = awayTeam.findElements("NameCoach").first.text;
      } else {
        awayCoachName = "AI";
      }
    }



    if (status == MatchStatus.unplayed) {
      homeScore = '?';
      awayScore = '?';
    }

    var scoreColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('', style: TextStyle(fontSize: 7.0, fontWeight: FontWeight.bold)),
          Text('$homeScore', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          Text('', style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
          Text('$awayScore', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        ]);

    var teamColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$homeTeamName', style: TextStyle(fontSize: 16.0)),
          Text('  $homeCoachName', style: TextStyle(fontSize: 14.0)),
          Text('$awayTeamName', style: TextStyle(fontSize: 16.0)),
          Text('  $awayCoachName', style: TextStyle(fontSize: 14.0)),
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

    return child;
  }
}