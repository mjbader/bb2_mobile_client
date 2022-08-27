import 'dart:collection';

import 'package:BB2Admin/bb2admin.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:bb2_mobile_app/types.dart';

class MatchItem extends StatefulWidget {
  final XmlElement matchElement;
  final HashMap<String?, XmlElement> participants;

  const MatchItem({Key? key, required this.matchElement, required this.participants}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    var status = int.parse(matchElement.findElements("IdStatus").first.text);
    var homeScore = matchElement.findElements("HomeScore").first.text;
    var homeTeamId = matchElement.findElements("IdTeamHome").first.firstChild?.text;
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
    var awayTeamId = matchElement.findElements("IdTeamAway").first.firstChild?.text;
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

  @override
  State<StatefulWidget> createState() => MatchItemState();
}

class MatchItemState extends State<MatchItem> {
  late String homeScore;
  late String awayScore;
  int status = MatchStatus.unplayed;
  String homeTeamName = "Loading...";
  String homeCoachName =  "Loading...";
  String awayTeamName = "Loading...";
  String awayCoachName = "Loading...";

  @override
  void initState() {
    super.initState();
    var status = int.parse(widget.matchElement.findElements("IdStatus").first.text);
    homeScore = widget.matchElement.findElements("HomeScore").first.text;
    var homeTeamId = widget.matchElement.findElements("IdTeamHome").first.firstChild?.text;
    var homeTeam = widget.participants[homeTeamId];

    if (homeTeam != null) {
      homeTeamName = homeTeam.findAllElements("Name").first.text;
      if (homeTeam.findElements("NameCoach").isNotEmpty) {
        homeCoachName = homeTeam.findElements("NameCoach").first.text;
      } else {
        homeCoachName = "AI";
      }
    }

    awayScore = widget.matchElement.findElements("AwayScore").first.text;
    var awayTeamId = widget.matchElement.findElements("IdTeamAway").first.firstChild?.text;
    var awayTeam = widget.participants[awayTeamId];
    if (awayTeam != null) {
      awayTeamName = awayTeam.findAllElements("Name").first.text;
      if (awayTeam.findElements("NameCoach").isNotEmpty) {
        awayCoachName = awayTeam.findElements("NameCoach").first.text;
      } else {
        awayCoachName = "AI";
      }
    }

    if (homeTeam == null || awayTeam == null) {
      loadFromMatchRecord();
    }

    if (status == MatchStatus.unplayed) {
      homeScore = '?';
      awayScore = '?';
    }
  }

  void loadFromMatchRecord() {
    var recordId = widget.matchElement.findAllElements("IdMatchRecord").first.text;
    BB2Admin.defaultManager.getMatchRecord(recordId).then((matchRecord) {
      setState(() {
        awayCoachName = matchRecord.findAllElements('CoachAwayName').first.text;
        awayTeamName = matchRecord.findAllElements('TeamAwayName').first.text;
        homeCoachName = matchRecord.findAllElements('CoachHomeName').first.text;
        homeTeamName = matchRecord.findAllElements('TeamHomeName').first.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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