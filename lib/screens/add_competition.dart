import 'package:flutter/material.dart';

class AddCompetition extends StatefulWidget {

  AddCompetition({Key? key, required this.leagueId, required this.leagueName}) : super(key: key);

  final String leagueId;
  final String leagueName;

  @override
  _AddCompetitionState createState() => _AddCompetitionState();
}

class _AddCompetitionState extends State<AddCompetition> {

  @override
  Widget build(BuildContext context) {
    var body = Row();
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Competition"),
      ),
      body: SafeArea(
        child: body,
        bottom: false,
      ),
    );
  }
}