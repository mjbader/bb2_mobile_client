import 'package:flutter/material.dart';
import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/matches.dart';
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
      body = ListView.builder(
        padding: EdgeInsets.all(8.0),
        itemCount: _competitions.length,
        itemBuilder: (BuildContext context, int index) {
          var name = _competitions[index]
              .findAllElements("Name")
              .first
              .text;
          var id = _competitions[index]
              .findAllElements("Id").first.children.first.text;
          return FlatButton(
              onPressed: () {
                var title = name;
                var compScreen = MatchesScreen(title: title, compId: id);
                Navigator.push(context, MaterialPageRoute(builder: (context) => compScreen));
              },
              child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$name', style: TextStyle(fontSize: 24.0)),
                    Divider()
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
