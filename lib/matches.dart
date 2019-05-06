import 'dart:collection';

import 'package:bb2_mobile_app/participants.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:BB2Admin/bb2admin.dart';

import 'package:bb2_mobile_app/match_item.dart';
import 'participant_list.dart';

class MatchesScreen extends StatefulWidget {
  MatchesScreen({Key key, this.title, this.compId}) : super(key: key);
  final String title;
  final String compId;

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

const COMP_WAITING = 0;
const COMP_RUNNING = 1;
const COMP_FINISHED = 2;

class _MatchesScreenState extends State<MatchesScreen> {
  XmlElement _compData;
  List<XmlElement> _matches;
  List<XmlElement> _weekMatches;
  HashMap<String, XmlElement> _participants;
  int _rounds;
  int _currentRound;
  int _selectedRound;
  bool _isEmpty = false;
  bool _requestSending = false;
  int _compStatus;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void incrementCurrentRound() {
    if (_selectedRound < _rounds) {
      setState(() {
        _selectedRound++;
        updateWeekMatches();
      });
    }
  }

  void decrementCurrentRound() {
    if (_selectedRound > 1) {
      setState(() {
        _selectedRound--;
        updateWeekMatches();
      });
    }
  }

  void updateWeekMatches() {
    _weekMatches = _matches.where((element) {
      int matchRound = int.parse(element
          .findElements("Row")
          .first
          .findElements("CompetitionRound")
          .first
          .text);
      return matchRound == _selectedRound;
    }).toList();
  }

  bool isReadyToAdvance() {
    return _weekMatches.every((element) {
      return int.parse(element
              .findElements("Matches")
              .first
              .findElements("RowCompetitionMatch")
              .first
              .findElements("IdStatus")
              .first
              .text) !=
          0;
    });
  }

  bool isReadyToStart() {
    if (_compData != null) {
      var compRow = _compData.findElements("RowCompetition").first;
      var teamMax = int.parse(compRow.findElements("NbTeamsMax").first.text);
      var teamReg =
      int.parse(compRow.findElements("NbRegisteredTeams").first.text);
      return _compStatus == 0 && teamReg == teamMax;
    }
    return false;
  }

  void advanceRound() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to advance the round?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('All unvalidated matches will be validated.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  var compId = _compData
                      .findAllElements("RowCompetition")
                      .first
                      .findElements("Id")
                      .first
                      .children
                      .first
                      .text;
                  setState(() {
                    _requestSending = true;
                  });
                  BB2Admin.defaultManager
                      .advanceCompetition(compId)
                      .then((element) {
                    setData(element);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void startComp() {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to start the round?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  var compId = _compData
                      .findAllElements("RowCompetition")
                      .first
                      .findElements("Id")
                      .first
                      .children
                      .first
                      .text;
                  setState(() {
                    _requestSending = true;
                  });
                  BB2Admin.defaultManager
                      .startCompetition(compId)
                      .then((element) {
                    refreshData();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void setData(XmlElement compData) {
    setState(() {
      _compData = compData;
      _matches = compData.findAllElements("CompetitionContest").toList();

      _participants = new HashMap<String, XmlElement>();
      compData.findAllElements("CompetitionParticipant").fold(_participants,
          (players, element) {
        var id = element.findAllElements("ID").first.children.first.text;
        players[id] = element;
        return players;
      });

      _currentRound =
          int.parse(compData.findAllElements("CurrentRound").first.text);
      _selectedRound = _currentRound;
      _compStatus = int.parse(compData
          .findElements("RowCompetition")
          .first
          .findElements("CompetitionStatus")
          .first
          .text);

      _requestSending = false;

      _rounds = int.parse(compData.findAllElements("NbRounds").first.text);

      if (_matches.length == 0) {
        _isEmpty = true;
        return;
      }
      updateWeekMatches();
    });
  }

  void refreshData() {
    setState(() {
      _matches = null;
    });

    BB2Admin.defaultManager.getCompetitionData(widget.compId).then((element) {
      setData(element);
    });
  }

  void goToParticipants() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ParticipantsScreen(
                  title: "${widget.title} - Participants",
                  participants: _participants.values.toList(),
                  compId: widget.compId,
                )));
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_matches == null) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Getting Matches...',
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
    } else if (_isEmpty) {
      var onPressed;

      if (isReadyToStart()) {
        onPressed = startComp;
      }
      List<Widget> children = [];

      if (_requestSending) {
        children += [CircularProgressIndicator()];
      } else {
        children += [
          RaisedButton.icon(
            icon: Icon(Icons.play_arrow),
            label: Text('Start Week'),
            onPressed: onPressed,
          )
        ];
      }
      children += [new Expanded(child: ParticipantList(
        compId: widget.compId,
        participants: _participants.values.toList(),
      ))];

      body = Column(
        children: children,
      );
    } else {
      var listView = ListView.builder(
//        padding: EdgeInsets.all(8.0),
        itemCount: _weekMatches.length,
        itemBuilder: (BuildContext context, int index) {
          var matchData = _weekMatches[index]
              .findElements("Matches")
              .first
              .findElements("RowCompetitionMatch")
              .first;
          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MatchItem(matchElement: matchData, participants: _participants),
                Divider()
              ]);
        },
      );

      var weekBar = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _selectedRound > 1 ? decrementCurrentRound : null),
            Text('Week $_selectedRound', style: TextStyle(fontSize: 20.0)),
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed:
                  _selectedRound < _rounds ? incrementCurrentRound : null,
            )
          ]);

      List<Widget> children = [
        weekBar,
      ];

      if (_requestSending) {
        children += [CircularProgressIndicator()];
      } else if (_currentRound == _selectedRound &&
          _compStatus != COMP_FINISHED) {
        Function onPressed = isReadyToAdvance() ? advanceRound : null;

        children += [
          RaisedButton.icon(
            icon: Icon(Icons.play_arrow),
            label: Text('Advance Week'),
            onPressed: onPressed,
          )
        ];
      }

      children += [Divider(), new Expanded(child: listView)];

      body = Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }

    List<Widget> actions = List<Widget>();

    if (_compStatus == 1) {
      actions += [
        IconButton(
          icon: Icon(Icons.person),
          tooltip: 'Participants',
          onPressed: goToParticipants,
        )
      ];
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title), actions: actions),
      body: body,
    );
  }
}
