import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/screens/competitions.dart';
import 'package:xml/xml.dart';

class LeagueScreen extends StatefulWidget {
  LeagueScreen({Key? key}) : super(key: key);

  @override
  _LeagueScreenState createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> {
  List<XmlElement>? _leagues;

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
    var body;

    if (_leagues == null) {
      body = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Getting Leagues...', style: Theme.of(context).textTheme.headline6
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: PlatformCircularProgressIndicator(),
            ),
          ],
        ),
      );
    } else {
      var leagues = _leagues!;
      body = ListView.separated(
        separatorBuilder: (BuildContext context, int index) => Container(color: Theme.of(context).dividerColor, height: 0.5, margin: EdgeInsets.all(0),),
        itemCount: leagues.length,
        itemBuilder: (BuildContext context, int index) {
          var name = leagues[index].findAllElements("Name").first.text;
          var leagueId = leagues[index].findAllElements("RowLeague").first.findAllElements("Id").first.firstChild!.text;
          return TextButton(
              onPressed: () {
                var title = name;
                var compScreen = CompetitionsScreen(title: title, leagueId: leagueId);
                Navigator.push(context, platformPageRoute(context: context, builder: (context) => compScreen,));
              },
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('$name', style: Theme.of(context).textTheme.headline6),
                  ])
          );
        },
      );
    }

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Leagues"),
      ),
      body: body
    );
  }
}
