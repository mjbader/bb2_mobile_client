import 'package:BB2Admin/bb2admin.dart';
import 'package:flutter/material.dart';

import 'dart:collection';

import 'package:xml/xml.dart';
 
class MatchReport extends StatefulWidget {
  final String matchId;

  MatchReport({Key? key, required this.matchId}) : super(key: key);

  @override
  _MatchReportState createState() => _MatchReportState();
}

class _TeamInfo {
  String teamName;
  String coachName;
  int score;

  _TeamInfo(this.teamName, this.coachName, this.score);
}

class _MatchReportState extends State<MatchReport> {
  static const statTypes = ['Inflicted', 'Sustained'];
  static const statNames = [
    'Tackles',
    'Injuries',
    'KO',
    'Casualties',
    'Dead',
    'Expulsions',
    'PushOuts',
    'Passes',
  ];
  static const _attributes = [
    'CashSpentInducements',
    'CashEarned',
    'SpirallingExpenses',
//    'Value',
    'OccupationOwn',
    'OccupationTheir',
    'WinningsDice'
//    'MVP'
  ];
  static const _teamTypes = ['Home', 'Away'];
  XmlElement? _matchRecord;

  LinkedHashMap<String, HashMap<String, String>>? _matchStats;

  _TeamInfo? homeInfo;

  _TeamInfo? awayInfo;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  LinkedHashMap<String, HashMap<String, String>> returnMatchStats() {
    var hashMap = LinkedHashMap<String, HashMap<String, String>>();

    var matchRow = _matchRecord!.findElements("Row").first;

    for (var attribute in _attributes) {
      hashMap[attribute] = HashMap<String, String>();
      for (var teamType in _teamTypes) {
        var key = "$teamType$attribute";
        hashMap[attribute]?["${teamType}Value"] =
            matchRow.findElements(key).first.text;
      }
    }

    var coachResults = _matchRecord!.findAllElements('CoachResult');
    var isHome = true;
    var ipAddressHashMap = HashMap<String, String>();
    for (var coachResult in coachResults) {
      var ipAddress = coachResult.getElement('IpAddress')?.text;
      ipAddressHashMap[isHome ? 'HomeValue' : 'AwayValue'] = ipAddress!;
      isHome = false;
    }
    hashMap['IpAddress'] = ipAddressHashMap;

    for (var statType in statTypes) {
      for (var statName in statNames) {
        for (var teamType in _teamTypes) {
          var key = "$teamType$statType$statName";
          var elements = matchRow.findElements(key);
          if (elements.isNotEmpty) {
            if (hashMap["$statType $statName"] == null) {
              hashMap["$statType $statName"] = HashMap<String, String>();
            }
            hashMap["$statType $statName"]?["${teamType}Value"] =
                elements.first.text;
          }
        }
      }
      for (var teamType in _teamTypes) {
        var teamName = matchRow.findElements("Team${teamType}Name").first.text;
        var coachName = matchRow.findElements("Coach${teamType}Name");
        var coachNameString = coachName.isNotEmpty ? coachName.first.text : "AI";
        var score = int.parse(matchRow.findElements("${teamType}Score").first.text);

        _TeamInfo generalInfo = _TeamInfo(teamName, coachNameString, score);
        if (teamType == "Away") {
          awayInfo = generalInfo;
        } else {
          homeInfo = generalInfo;
        }
      }
    }
    return hashMap;
  }

  void refreshData() {
//    var matchRecord = matchRecordMock;
    BB2Admin.defaultManager.getMatchRecord(widget.matchId).then((matchRecord) {
      setState(() {
        _matchRecord = matchRecord;
        _matchStats = returnMatchStats();
      });
    });
  }

  Widget renderColumns() {
    var columns = <Widget>[];
    columns += [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var key in _matchStats!.keys) Text(_matchStats![key]!["HomeValue"]!),
        ],
      )
    ];
      columns += [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var key in _matchStats!.keys) Text(key),
        ],
      )
    ];
      columns += [
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          for (var key in _matchStats!.keys) Text(_matchStats![key]!["AwayValue"]!),
        ],
      )
    ];
    return Row(children: columns, mainAxisAlignment: MainAxisAlignment.spaceAround,);
  }

  @override
  Widget build(BuildContext context) {
    var body;
    if (_matchRecord == null) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Getting Match Info...',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      var headerInfo = Row(children: <Widget>[
        Column(children: <Widget>[
          Text(homeInfo!.teamName, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),),
          Text(homeInfo!.coachName),
        ],
          crossAxisAlignment: CrossAxisAlignment.start,),
        Column(children: <Widget>[
          Text(awayInfo!.teamName, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold)),
          Text(awayInfo!.coachName),
        ],
          crossAxisAlignment: CrossAxisAlignment.end,)
      ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween);
      body = SingleChildScrollView(
        child: Column(children: <Widget>[
          headerInfo,
          Text("${homeInfo!.score.toString()} - ${awayInfo!.score.toString()}", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          Divider(),
          renderColumns()
        ],),
      );
    }

    return Scaffold(
        appBar: AppBar(title: Text("Match Info")),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SafeArea(child: body, bottom: false)));
  }
}
