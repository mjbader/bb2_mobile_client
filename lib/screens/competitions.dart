import 'package:bb2_mobile_app/screens/add_competition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'dart:io';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/screens/matches.dart';
import 'package:bb2_mobile_app/types.dart';
import 'package:bb2_mobile_app/common_widgets/list_item.dart';
import 'package:xml/xml.dart';

class CompetitionsScreen extends StatefulWidget {
  CompetitionsScreen({Key key, this.title, this.leagueId}) : super(key: key);
  final String title;
  final String leagueId;

  @override
  _CompetitionsScreenState createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  List<XmlElement> _competitions;
  bool _editMode = false;
  Set<int> _isSelected = Set<int>();

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() {
    BB2Admin.defaultManager.getCompetitions(widget.leagueId).then((elements) {
      setState(() {
        _competitions = elements.toList();
        _competitions.sort((a, b) {
          var aStatus = int.parse(a
              .findElements("Row")
              .first
              .findElements("CompetitionStatus")
              .first
              .text);
          var bStatus = int.parse(b
              .findElements("Row")
              .first
              .findElements("CompetitionStatus")
              .first
              .text);
          return aStatus - bStatus;
        });
      });
    });
  }

  void pushAddCompetitionScreen() {
    Navigator.push(context,
        platformPageRoute(builder: (context) => AddCompetition()));
  }

  void showDeleteConfirmDialog() {
    showPlatformDialog(
        context: context,
        builder: (BuildContext context) {
          return PlatformAlertDialog(
            title: Text('Are you sure you want to delete these competitions?'),
            content: Text('This action is irreversible.'),
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
                  deleteSelectedCompetitions();
                  setState(() {
                    _competitions = null;
                    _editMode = false;
                    _isSelected.clear();
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void deleteSelectedCompetitions() {
    var compIds = _isSelected.map((index) {
      return _competitions[index]
          .findElements("Row")
          .first
          .findElements("Id")
          .first
          .firstChild
          .text;
    });

    var deleteFutures = compIds.map((id) {
      return BB2Admin.defaultManager.deleteCompetition(id);
    });

    Future.wait(deleteFutures).then((values) {
      refreshData();
    });
  }

  void addCompetitionPushed() {}

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_competitions == null) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Getting Competitions...',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: PlatformCircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      body = ListView.separated(
        padding: EdgeInsets.all(8.0),
        itemCount: _competitions.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          var compRow = _competitions[index].findElements("Row").first;
          var name = compRow.findElements("Name").first.text;
          var id = compRow.findElements("Id").first.firstChild.text;

          var status =
              int.parse(compRow.findElements("CompetitionStatus").first.text);

          var statusText;
          switch (status) {
            case CompetitionStatus.waiting:
              var teamMax =
                  int.parse(compRow.findElements("NbTeamsMax").first.text);
              var teamReg = int.parse(
                  compRow.findElements("NbRegisteredTeams").first.text);
              if (teamMax == teamReg) {
                statusText = "Ready to Start";
              } else {
                statusText =
                    "Waiting for ${teamMax - teamReg} out of $teamMax teams";
              }
              break;
            case CompetitionStatus.running:
              var rounds =
                  int.parse(compRow.findElements("NbRounds").first.text);
              var curRound =
                  int.parse(compRow.findElements("CurrentRound").first.text);

              statusText = "Running";

              if (rounds > 0) {
                statusText += " - Round $curRound/$rounds";
              }
              break;
            case CompetitionStatus.completed:
              statusText = "Completed";
              break;
            case CompetitionStatus.paused:
              statusText = "Paused";
              break;
            default:
              statusText = "Unknown";
          }

          var type =
              int.parse(compRow.findElements("IdCompetitionTypes").first.text);
          var compTypeText;
          switch (type) {
            case CompetitionType.roundRobin:
              compTypeText = "Round Robin";
              break;
            case CompetitionType.knockout:
              compTypeText = "Knockout";
              break;
            case CompetitionType.ladder:
              compTypeText = "Ladder (Does not work TODO)";
              break;
            case CompetitionType.swiss:
              compTypeText = "Swiss";
              break;
            default:
              compTypeText = "Unknown";
          }

          var element;
          var matchInfo = Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('$name', style: TextStyle(fontSize: 18.0)),
                Text('$compTypeText',
                    style: TextStyle(fontSize: 16.0, color: Colors.black87)),
                Text('$statusText',
                    style: TextStyle(fontSize: 16.0, color: Colors.black54)),
              ]);

          element = ListItem(
              child: matchInfo,
              isEditable: _editMode,
              isSelected: _isSelected.contains(index),
              onChanged: (value) {
                setState(() {
                  if (_isSelected.contains(index)) {
                    _isSelected.remove(index);
                  } else {
                    _isSelected.add(index);
                  }
                });
              });

          return GestureDetector(
              onTapUp: (details) {
                if (_editMode) {
                  setState(() {
                    if (_isSelected.contains(index)) {
                      _isSelected.remove(index);
                    } else {
                      _isSelected.add(index);
                    }
                  });
                } else {
                  var title = name;
                  var compScreen = MatchesScreen(
                    title: title,
                    compId: id,
                    compChanged: refreshData,
                  );
                  Navigator.push(context,
                      platformPageRoute(builder: (context) => compScreen));
                }
              },
              onLongPress: () {
                setState(() {
                  if (!_editMode) {
                    _editMode = true;
                    _isSelected.add(index);
                  }
                });
              },
              onLongPressStart: (details) {},
              child: element);
        },
      );
    }

    var deleteFunction =
        _isSelected.isNotEmpty ? showDeleteConfirmDialog : null;
    List<Widget> trailingActions = [
      if (_editMode)
        PlatformIconButton(
          icon: Icon(Icons.delete),
          onPressed: deleteFunction,
        ),
      if (!_editMode)
        PlatformIconButton(
          icon: Icon(Icons.edit),
          onPressed: () => setState(() {
                _editMode = true;
              }),
        )
    ];

    var addCompPush = pushAddCompetitionScreen;

    Widget leadingAction = _editMode
        ? PlatformIconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              setState(() {
                _editMode = false;
                _isSelected.clear();
              });
            },
          )
        : null;

    if (Platform.isIOS) {
      if (_editMode) {
        leadingAction = CupertinoButton(
          child: PlatformText("Cancel"),
          onPressed: () => setState(() {
                _editMode = false;
                _isSelected.clear();
              }),
          padding: EdgeInsets.all(0),
        );
        trailingActions = [
          CupertinoButton(
            child: PlatformText("Delete"),
            onPressed: deleteFunction,
            padding: EdgeInsets.all(0),
          )
        ];
      } else {
        trailingActions = [
          PlatformIconButton(
            icon: Icon(
              CupertinoIcons.add,
              size: 40,
            ),
            onPressed: addCompPush,
            padding: EdgeInsets.only(bottom: 10),
          )
        ];
      }
    }

    return PlatformScaffold(
      android: (context) => MaterialScaffoldData(
              floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: addCompPush,
          )),
      appBar: PlatformAppBar(
        title: PlatformText(widget.title),
        trailingActions: trailingActions,
        leading: leadingAction,
      ),
      body: SafeArea(
        child: body,
        bottom: false,
      ),
    );
  }
}
