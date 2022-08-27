// import 'package:bb2_mobile_app/screens/add_competition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/screens/matches.dart';
import 'package:bb2_mobile_app/types.dart';
import 'package:bb2_mobile_app/common_widgets/list_item.dart';
import 'package:xml/xml.dart';

class CompetitionsScreen extends StatefulWidget {
  CompetitionsScreen({Key? key, required this.title, required this.leagueId}) : super(key: key);
  final String title;
  final String leagueId;

  @override
  _CompetitionsScreenState createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  List<XmlElement>? _competitions;
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
        _competitions?.sort((a, b) {
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

  // void pushAddCompetitionScreen() {
  //   Navigator.push(
  //       context,
  //       platformPageRoute(
  //           context: context, builder: (context) => AddCompetition()));
  // }

  void showDeleteConfirmDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure you want to delete these competitions?'),
            content: Text('This action is irreversible.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
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
      return _competitions![index]
          .findElements("Row")
          .first
          .findElements("Id")
          .first
          .firstChild!
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
                style: Theme.of(context).textTheme.headline6
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: CircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      body = ListView.separated(
        padding: EdgeInsets.all(8.0),
        itemCount: _competitions?.length ?? 0,
        separatorBuilder: (BuildContext context, int index) => Divider(height: 16,),
        itemBuilder: (BuildContext context, int index) {
          var compRow = _competitions![index].findElements("Row").first;
          var name = compRow.findElements("Name").first.text;
          var id = compRow.findElements("Id").first.firstChild!.text;

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
                Text('$name', style: Theme.of(context).textTheme.headline6),
                Text('$compTypeText',
                    style: Theme.of(context).textTheme.subtitle1),
                Text('$statusText',
                    style: Theme.of(context).textTheme.subtitle2),
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => compScreen));
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
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: deleteFunction,
        ),
      if (!_editMode)
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () => setState(() {
            _editMode = true;
          }),
        )
    ];

    Widget? leadingAction = _editMode
        ? IconButton(
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
          child: Text("Cancel"),
          onPressed: () => setState(() {
            _editMode = false;
            _isSelected.clear();
          }),
          padding: EdgeInsets.all(0),
        );
        trailingActions = [
          CupertinoButton(
            child: Text("Delete"),
            onPressed: deleteFunction,
            padding: EdgeInsets.all(0),
          )
        ];
      }
//      } else {
//        trailingActions = [
//          IconButton(
//            icon: Icon(
//              CupertinoIcons.add,
//              size: 40,
//            ),
//            onPressed: addCompPush,
//            padding: EdgeInsets.only(bottom: 10),
//          )
//        ];
//      }
    }

    return Scaffold(
//       material: (context, platformTarget) => MaterialScaffoldData(
// //          floatingActionButton: FloatingActionButton(
// //        child: Icon(Icons.add),
// //        onPressed: addCompPush,
//           ),
      appBar: AppBar(
        title: Text(widget.title),
        actions: trailingActions,
        leading: leadingAction,
      ),
      body: SafeArea(
        child: body,
        bottom: false,
      ),
    );
  }
}
