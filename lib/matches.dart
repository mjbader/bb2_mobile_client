import 'dart:collection';

import 'package:bb2_mobile_app/participants.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:BB2Admin/bb2admin.dart';

import 'package:bb2_mobile_app/match_item.dart';
import 'participant_list.dart';
import 'types.dart';

class MatchesScreen extends StatefulWidget {
  MatchesScreen({Key key, this.title, this.compId}) : super(key: key);
  final String title;
  final String compId;

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

enum _MatchOptions { validate, reset }

class _MatchesScreenState extends State<MatchesScreen> {
  XmlElement _compData;
  List<XmlElement> _matches;
  List<XmlElement> _weekMatches;
  HashMap<String, XmlElement> _participants;
  int _rounds;
  int _currentRound;
  int _selectedRound;
  bool _requestSending = false;
  int _compStatus;
  int _maxTeams;
  int _regTeams;
  int _compType;

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
      return _compStatus == 0 && _regTeams == _maxTeams;
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

  void _validateMatch(String matchId) {
    var compId = _compData
        .findAllElements("RowCompetition")
        .first
        .findElements("Id")
        .first
        .children
        .first
        .text;

    setState(() {
      _matches = null;
    });

    BB2Admin.defaultManager.validateMatch(matchId, compId).then((data) => setData(data));
  }

  void _resetMatch(String matchId) {
    var compId = _compData
        .findAllElements("RowCompetition")
        .first
        .findElements("Id")
        .first
        .children
        .first
        .text;

    setState(() {
      _matches = null;
    });

    BB2Admin.defaultManager.resetMatch(matchId, compId).then((data) => setData(data));
  }

  void _matchSelected(int status, BuildContext context, Widget match, String matchId) async {
    if (status == MatchStatus.unvalidated) {
      switch (await showDialog<_MatchOptions>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              title: const Text('Admin Match Options'),
              children: <Widget>[
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, _MatchOptions.validate);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.check),
                      Text('  Validate', style: TextStyle(fontSize: 20))
                    ],
                  ),
                ),
                SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, _MatchOptions.reset);
                  },
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.cancel),
                      Text('  Reset', style: TextStyle(fontSize: 20))
                    ],
                  ),
                ),
              ],
            );
          })) {
        case _MatchOptions.validate:
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Are you sure wish to validate this match?"),
                  content: SingleChildScrollView(child: match),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Validate'),
                      onPressed: () {
                        _validateMatch(matchId);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          break;
        case _MatchOptions.reset:
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Are you sure wish to reset this match?"),
                  content: SingleChildScrollView(child: match),
                  actions: <Widget>[
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    FlatButton(
                      child: Text('Reset'),
                      onPressed: () {
                        _resetMatch(matchId);
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              });
          break;
      }
    }
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

      _maxTeams = int.parse(compData
          .findElements("RowCompetition")
          .first
          .findElements("NbTeamsMax")
          .first
          .text);
      _regTeams = int.parse(compData
          .findElements("RowCompetition")
          .first
          .findElements("NbRegisteredTeams")
          .first
          .text);

      _compType = int.parse(compData
          .findElements("RowCompetition")
          .first
          .findElements("IdCompetitionTypes")
          .first.text);

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

      if (_matches.length != 0) {
        updateWeekMatches();
      }
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
    var inComp = _participants.values.where((element) {
      var status =
          int.parse(element.findElements("IdTeamCompetitionStatus").first.text);
      return status == 1;
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ParticipantsScreen(
                  title: "${widget.title} - Participants",
                  participants: inComp.toList(),
                  compId: widget.compId,
                  maxTeams: _maxTeams,
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
          ],
        ),
      );
    } else if (_compStatus == 0 || _compType == CompetitionType.ladder) {
      var onPressed;

      if (isReadyToStart()) {
        onPressed = startComp;
      }
      List<Widget> children = [];

      if (_requestSending) {
        children += [
          Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          )
        ];
      } else {
        children += [
          Padding(
            padding: EdgeInsets.all(10),
            child: RaisedButton.icon(
              icon: Icon(Icons.play_arrow),
              label: Text('Start Competition'),
              onPressed: onPressed,
            ),
          )
        ];
      }
      children += [
        new Expanded(
            child: ParticipantList(
                compId: widget.compId,
                participants: _participants.values.toList(),
                maxTeams: _maxTeams))
      ];

      body = Column(
        children: children,
      );
    } else {
      var listView = ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemCount: _weekMatches.length,
        itemBuilder: (BuildContext context, int index) {
          var matchData = _weekMatches[index]
              .findElements("Matches")
              .first
              .findElements("RowCompetitionMatch")
              .first;

          Function onPressed;
          var matchItem = MatchItem(matchElement: matchData, participants: _participants);
          var status = int.parse(matchData.findElements("IdStatus").first.text);
          var id = matchData.findElements("Id").first.children.first.text;
          if (status != MatchStatus.validated) {
            onPressed = () => _matchSelected(status, context, matchItem, id);
          }

          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              FlatButton(child: matchItem, onPressed: onPressed,),
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
          _compStatus != CompetitionStatus.completed) {
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
