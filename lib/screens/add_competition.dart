import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class AddCompetition extends StatefulWidget {

  AddCompetition({Key key, this.leagueId, this.leagueName}) : super(key: key);

  final String leagueId;
  final String leagueName;

  @override
  _AddCompetitionState createState() => _AddCompetitionState();
}

class _AddCompetitionState extends State<AddCompetition> {

  @override
  Widget build(BuildContext context) {
    var body = Row();
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: PlatformText("Add Competition"),
      ),
      body: SafeArea(
        child: body,
        bottom: false,
      ),
    );
  }
}