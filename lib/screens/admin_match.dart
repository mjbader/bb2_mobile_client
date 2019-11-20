import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:bb2_mobile_app/common_widgets//number_textfield_buttons.dart';

import 'package:BB2Admin/bb2admin.dart';

class AdminMatchScreen extends StatefulWidget {
  AdminMatchScreen(
      {Key key, this.matchId, this.compId, this.participants, this.onComplete})
      : super(key: key);

  @override
  State createState() => _AdminMatchScreenState();

  final String matchId;
  final String compId;
  final List<XmlElement> participants;
  final Function onComplete;
}

enum _TeamType { home, away }

class _AdminMatchScreenState extends State<AdminMatchScreen> {
  bool isConcede = false;
  bool randWinAway = true;
  bool randWinHome = true;
  bool submitting = false;
  int homeScore = 0;
  int awayScore = 0;
  int winDiceHome;
  int winDiceAway;

  void onSubmit(BuildContext context) {
    setState(() {
      submitting = true;
    });
    BB2Admin.defaultManager
        .adminMatchQuick(widget.matchId, widget.compId, isConcede, homeScore,
            awayScore, winDiceHome, winDiceAway)
        .then((value) {
      Navigator.pop(context);
      widget.onComplete();
    });
  }

  Widget randWinSwitch(_TeamType teamType) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
      PlatformSwitch(
          onChanged: (bool value) {
            setState(() {
              if (teamType == _TeamType.home)
                randWinHome = value;
              else
                randWinAway = value;

              if (teamType == _TeamType.home) {
                if (value == true)
                  winDiceHome = null;
                else
                  winDiceHome = 1;
              } else {
                if (value == true)
                  winDiceAway = null;
                else
                  winDiceAway = 1;
              }
            });
          },
          value: teamType == _TeamType.home ? randWinHome : randWinAway),
      Text('Rand Winnings')
    ]);
  }

  Widget TeamSide(_TeamType teamType) {
    int index = 0;
    if (teamType == _TeamType.away) {
      index = 1;
    }

    var winningsDiceLabel;
    if (teamType == _TeamType.home
        ? winDiceHome != null
        : winDiceAway != null)
      winningsDiceLabel = "Winning Dice";

    return Wrap(
        spacing: 10,
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceAround,
        children: <Widget>[

          Text(
            widget.participants[index].findAllElements("Name").first.text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          if (widget.participants[index]
              .findAllElements("NameCoach")
              .isNotEmpty)
            Text(widget.participants[index]
                .findAllElements("NameCoach")
                .first
                .text),

            NumberPicker(
              label: "Touchdowns",
              value: teamType == _TeamType.home ? homeScore : awayScore,
              min: 0,
              onChanged: (int value) {
                setState(() {
                  if (teamType == _TeamType.home)
                    homeScore = value;
                  else
                    awayScore = value;
                });
              }),


          randWinSwitch(teamType),

          if (teamType == _TeamType.home
              ? winDiceHome != null
              : winDiceAway != null)
            NumberPicker(
                label: winningsDiceLabel,
                value: teamType == _TeamType.home ? winDiceHome : winDiceAway,
                min: 1,
                max: 6,
                onChanged: (int value) {
                  setState(() {
                    if (teamType == _TeamType.home)
                      winDiceHome = value;
                    else
                      winDiceAway = value;
                  });
                }),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (submitting) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Applying Adminned Game',
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: PlatformCircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      body = Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TeamSide(_TeamType.home),
                TeamSide(_TeamType.away)
              ]),
          if (homeScore != awayScore)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                PlatformSwitch(
                  onChanged: (bool value) {
                    setState(() {
                      isConcede = value;
                    });
                  },
                  value: isConcede,
                ),
                Text('Is Concede', style: TextStyle(fontSize: 16.0))
              ],
            ),
          PlatformButton(
            child: Text("Submit"),
            onPressed: () => onSubmit(context),
          ),
        ],
      );
    }
    return PlatformScaffold(
        appBar: PlatformAppBar(title: Text("Admin Match")),
        body: SafeArea(child: Padding(child: body, padding: EdgeInsets.symmetric(vertical: 50),), bottom: false));
  }
}
