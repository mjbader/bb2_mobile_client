import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'participant_list.dart';

class ParticipantsScreen extends StatelessWidget {
  final List<XmlElement> participants;
  final String title;
  final String compId;
  final int maxTeams;

  const ParticipantsScreen({Key key, this.title, this.participants, this.compId, this.maxTeams}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    var body = ParticipantList(compId: compId, participants: participants, maxTeams: maxTeams,);

    return Scaffold(
      appBar: AppBar(
        title: Text(this.title),
      ),
      body: body,
    );
  }
}