import 'dart:collection';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:bb2_mobile_app/cross_platform_widgets/cpactionsheet.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import 'package:BB2Admin/bb2admin.dart';

import 'package:bb2_mobile_app/common_widgets/match_item.dart';
import 'package:bb2_mobile_app/common_widgets/participant_list.dart';
import 'package:bb2_mobile_app/screens/match_report.dart';
import 'package:bb2_mobile_app/screens/admin_match.dart';
import 'package:bb2_mobile_app/screens/coach_search_delegate.dart';
import 'package:bb2_mobile_app/types.dart';
import 'package:bb2_mobile_app/themes/themes.dart';
import 'package:bb2_mobile_app/common_widgets/app_alert_dialog.dart';


class MatchesScreen extends StatefulWidget {
  MatchesScreen({Key key, this.title, this.compId, this.compChanged})
      : super(key: key);
  final String title;
  final String compId;
  final Function compChanged;

  @override
  _MatchesScreenState createState() => _MatchesScreenState();
}

enum _MatchOptions { validate, reset, info, admin }

class _MatchesScreenState extends State<MatchesScreen> {
  XmlElement _compData;
  List<XmlElement> _matches;
  List<XmlElement> _weekMatches;
  HashMap<String, XmlElement> _participants;
  List<XmlElement> _inComp = [];
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
    showPlatformDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AppAlertDialog(
            title: Text('Are you sure you want to advance the round?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('All unvalidated matches will be validated.'),
                ],
              ),
            ),
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
                    updateData(compData: element);
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void startComp() {
    showPlatformDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AppAlertDialog(
            title: Text('Are you sure you want to start the round?'),
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
                    updateData();
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

    BB2Admin.defaultManager
        .validateMatch(matchId, compId)
        .then((data) => updateData(compData: data));
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

    BB2Admin.defaultManager
        .resetMatch(matchId, compId)
        .then((data) => updateData(compData: data));
  }

  void _matchSelected(
      int status, BuildContext context, MatchItem match, String matchId) async {
    List<PlatformActionSheetAction<_MatchOptions>> children = [];
    switch (status) {
      case MatchStatus.unvalidated:
        children += [
          PlatformActionSheetAction<_MatchOptions>(
            result: _MatchOptions.validate,
            widget: Row(
              mainAxisAlignment: Platform.isIOS
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.check, color: AppTheme.getTextColor()),
                Text('  Validate', style: TextStyle(fontSize: 20))
              ],
            ),
          ),
          PlatformActionSheetAction<_MatchOptions>(
            result: _MatchOptions.reset,
            widget: Row(
              mainAxisAlignment: Platform.isIOS
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.cancel, color: AppTheme.getTextColor()),
                Text('  Reset', style: TextStyle(fontSize: 20))
              ],
            ),
          )
        ];
        continue validated;
      validated:
      case MatchStatus.validated:
        children += [
          PlatformActionSheetAction<_MatchOptions>(
            result: _MatchOptions.info,
            widget: Row(
              mainAxisAlignment: Platform.isIOS
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.info, color: AppTheme.getTextColor()),
                Text('  Info', style: TextStyle(fontSize: 20))
              ],
            ),
          ),
        ];
        break;
      case MatchStatus.unplayed:
        children += [
          PlatformActionSheetAction<_MatchOptions>(
            result: _MatchOptions.admin,
            widget: Row(
              mainAxisAlignment: Platform.isIOS
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.build, color: AppTheme.getTextColor(),),
                Text('  Admin Match', style: TextStyle(fontSize: 20))
              ],
            ),
          ),
        ];
        break;
    }

    switch (await showPlatformActionSheet(
        context: context, title: 'Admin Match Options', children: children)) {
      case _MatchOptions.validate:
        showPlatformDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: Text("Are you sure wish to validate this match?"),
                content: SingleChildScrollView(child: match),
                actions: <Widget>[
                  PlatformDialogAction(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  PlatformDialogAction(
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
        showPlatformDialog(
            context: context,
            builder: (BuildContext context) {
              return AppAlertDialog(
                title: Text("Are you sure wish to reset this match?"),
                content: SingleChildScrollView(child: match),
                actions: <Widget>[
                  PlatformDialogAction(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  PlatformDialogAction(
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
      case _MatchOptions.info:
        var recordId =
            match.matchElement.findAllElements("IdMatchRecord").first.text;
        Navigator.push(
            context,
            platformPageRoute(
                context: context,
                builder: (context) => MatchReport(
                      matchId: recordId,
                    )));
        break;
      case _MatchOptions.admin:
        var homeTeamId =
            match.matchElement.findElements("IdTeamHome").first.firstChild.text;
        var awayTeamId =
            match.matchElement.findElements("IdTeamAway").first.firstChild.text;
        Navigator.push(
            context,
            platformPageRoute(
                context: context,
                builder: (context) => AdminMatchScreen(
                      matchId: matchId,
                      compId: widget.compId,
                      participants: [
                        _participants[homeTeamId],
                        _participants[awayTeamId]
                      ],
                      onComplete: this.onMatchAdminned,
                    )));
        break;
    }
  }

  void onMatchAdminned() {
    setState(() {
      _matches = null;
    });
    updateData();
  }

  void setData(XmlElement compData) {
    setState(() {
      _compData = compData;
      _matches = compData.findAllElements("CompetitionContest").toList();

      _participants = new HashMap<String, XmlElement>();
      compData.findAllElements("CompetitionParticipant").fold(_participants,
          (players, element) {
        var id = element.findAllElements("ID").first.firstChild.text;
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
          .first
          .text);

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

  void updateData({XmlElement compData}) {
    widget.compChanged();

    if (compData != null) {
      setData(compData);
    } else {
      refreshData();
    }
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
        platformPageRoute(
            context: context,
            maintainState: false,
            builder: (context) {
              return PlatformScaffold(
                appBar: PlatformAppBar(
                  title: Text("${widget.title}"),
                  trailingActions: [
                    PlatformIconButton(
                      icon: Icon(Icons.search),
                      onPressed: searchForTeam,
                    )
                  ],
                ),
                body: SafeArea(
                  child: ParticipantList(
                    compId: widget.compId,
                    maxTeams: _maxTeams,
                    onKick: () => this.updateData(),
                  ),
                  bottom: false,
                ),
              );
            }));
  }

  void addAI() {
    var leagueId = _compData
        .findElements("RowLeague")
        .first
        .findElements("Id")
        .first
        .firstChild
        .text;
    BB2Admin.defaultManager.addAIToComp(widget.compId, leagueId).then((value) {
      updateData();
    });
  }

  void searchForTeam() async {
    var resultFuture =
        showSearch(context: context, delegate: CoachSearchDelegate(context));
    resultFuture.then((result) {
      var leagueId = _compData
          .findElements("RowLeague")
          .first
          .findElements("Id")
          .first
          .firstChild
          .text;
      if (result != null) {
        var ticketSendFuture = BB2Admin.defaultManager.createAndSendTicket(
            leagueId, widget.compId, result.coachId, result.teamId);
        ticketSendFuture.then((response) {
          refreshData();
        });
      }
    });
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
              style: Theme.of(context).textTheme.headline6
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: PlatformCircularProgressIndicator(),
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
            child: PlatformCircularProgressIndicator(),
          )
        ];
      } else {
        children += [
          Padding(
            padding: EdgeInsets.all(10),
            child: PlatformButton(
//              icon: Icon(Icons.play_arrow),
              child: Text('Start Competition'),
              onPressed: onPressed,
            ),
          )
        ];
      }
      children += [
        new Expanded(
            child: ParticipantList(
          compId: widget.compId,
          maxTeams: _maxTeams,
          onKick: () => this.updateData(),
        ))
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
          var matchItem =
              MatchItem(matchElement: matchData, participants: _participants);
          var status = int.parse(matchData.findElements("IdStatus").first.text);
          var id = matchData.findElements("Id").first.firstChild.text;
          onPressed = () => _matchSelected(status, context, matchItem, id);

          return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                    child: matchItem,
                    onPressed: onPressed,
                    style: TextButton.styleFrom(
                      primary: status == 2 ? Colors.grey : AppTheme.getTextColor())
                    )
              ]);
        },
      );

      var weekBar = Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PlatformIconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: _selectedRound > 1 ? decrementCurrentRound : null),
            Text('Week $_selectedRound', style: TextStyle(fontSize: 20.0)),
            PlatformIconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed:
                  _selectedRound < _rounds ? incrementCurrentRound : null,
            )
          ]);

      List<Widget> children = [
        weekBar,
      ];

      if (_requestSending) {
        children += [PlatformCircularProgressIndicator()];
      } else if (_currentRound == _selectedRound &&
          _compStatus != CompetitionStatus.completed) {
        Function onPressed = isReadyToAdvance() ? advanceRound : null;

        children += [
          PlatformButton(
//            icon: Icon(Icons.play_arrow),
            child: Text('Advance Week'),
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

    List<Widget> actions = [];

    if (_compStatus == 0 &&
        !isReadyToStart()) {
      if (_inComp.length < _maxTeams) {
        actions += [
          PlatformIconButton(
            icon: Icon(Icons.plus_one),
            onPressed: addAI,
          ),
        ];
      }
      actions += [
        PlatformIconButton(
          icon: Icon(Icons.search),
          onPressed: searchForTeam,
        )
      ];
    }

    if (_compStatus == 1) {
      actions += [
        PlatformIconButton(
          icon: Icon(Icons.person),
          onPressed: goToParticipants,
        )
      ];
    }

    return PlatformScaffold(
        appBar:
            PlatformAppBar(title: Text(widget.title), trailingActions: actions),
        body: SafeArea(child: body, bottom: false));
  }
}
