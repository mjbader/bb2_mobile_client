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

    if (status == MatchStatus.unplayed) {
      homeScore = '?';
      awayScore = '?';
    }

    var scoreColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$homeScore', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          Text('$awayScore', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
        ]);

    var teamColumn = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$homeTeamName', style: TextStyle(fontSize: 16.0)),
          Text('$awayTeamName', style: TextStyle(fontSize: 16.0)),
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