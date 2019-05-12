import 'package:flutter/material.dart';
import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/matches.dart';
import 'types.dart';
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

  @override void initState() {
    super.initState();
    BB2Admin.defaultManager.getCompetitions(widget.leagueId).then((elements) {
        setState(() {
          _competitions = elements.toList();
          _competitions.sort((a, b) {
            var aStatus = int.parse(a.findElements("Row").first.findElements("CompetitionStatus").first.text);
            var bStatus = int.parse(b.findElements("Row").first.findElements("CompetitionStatus").first.text);
            return aStatus - bStatus;
          });
        });
      });
  }

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
              child: CircularProgressIndicator(),
            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.display1,
//            ),
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
          var name = compRow
              .findElements("Name")
              .first
              .text;
          var id = compRow.findElements("Id").first.children.first.text;

          var status = int.parse(compRow.findElements("CompetitionStatus").first.text);

          var statusText;
          switch(status) {
            case CompetitionStatus.waiting:
              var teamMax = int.parse(compRow.findElements("NbTeamsMax").first.text);
              var teamReg = int.parse(compRow.findElements("NbRegisteredTeams").first.text);
              if (teamMax == teamReg) {
                statusText = "Ready to Start";
              } else {
                statusText = "Waiting for Teams";
              }
              break;
            case CompetitionStatus.running:
              var rounds = int.parse(compRow.findElements("NbRounds").first.text);
              var curRound = int.parse(compRow.findElements("CurrentRound").first.text);

              statusText = "Running";

              if (rounds > 0) {
                statusText +=  " - Round $curRound/$rounds";
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

          var type = int.parse(compRow.findElements("IdCompetitionTypes").first.text);
          var compTypeText;
          switch(type) {
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

          return FlatButton(
              onPressed: () {
                var title = name;
                var compScreen = MatchesScreen(title: title, compId: id);
                Navigator.push(context, MaterialPageRoute(builder: (context) => compScreen));
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('$name', style: TextStyle(fontSize: 18.0)),
                    Text('$compTypeText', style: TextStyle(fontSize: 16.0, color: Colors.black87)),
                    Text('$statusText', style: TextStyle(fontSize: 16.0, color: Colors.black54)),
                  ]
              ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
          )
        ],
      ),
      body: body // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
