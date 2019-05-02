import 'package:flutter/material.dart';
import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/competitions.dart';
import 'package:xml/xml.dart';

class LeagueScreen extends StatefulWidget {
  LeagueScreen({Key key}) : super(key: key);

  @override
  _LeagueScreenState createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> {
  List<XmlElement> _leagues;

  @override void initState() {
    super.initState();
    BB2Admin.defaultManager.getAdminLeagues().then((elements) {
      setState(() {
        _leagues = elements.toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    if (_leagues == null) {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Leagues"),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Getting Leagues...',
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text("Leagues"),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(8.0),
//          itemExtent: 50.0,
          itemCount: _leagues.length,
          itemBuilder: (BuildContext context, int index) {
            var name = _leagues[index].findAllElements("Name").first.text;
            var leagueId = _leagues[index].findAllElements("RowLeague").first.findAllElements("Id").first.children.first.text;
            return FlatButton(
                onPressed: () {
                  var title = name;
                  var compScreen = CompetitionsScreen(title: title, leagueId: leagueId);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => compScreen));
                },
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('$name', style: TextStyle(fontSize: 24.0)),
                Divider()
              ])
            );
          },
        )
      );
    }
  }
}
