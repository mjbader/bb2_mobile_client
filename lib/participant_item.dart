import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class ParticipantItem extends StatelessWidget {
  final XmlElement participant;

  const ParticipantItem({Key key, this.participant}) : super(key:key);

  @override
  Widget build(BuildContext context) {

    var teamName;
    var teamNameElements = participant.findAllElements("RowTeam").first.findElements("Name");
    if (teamNameElements.isEmpty) {
      teamName = "Unknown";
    } else {
      teamName = teamNameElements.first.text;
    }

    var coachName;
    var coachNameElements;
    if (participant.name.toString() == "CompetitionParticipant") {
      coachNameElements = participant.findAllElements("NameCoach");
      var status = int.parse(participant.findElements("IdTeamCompetitionStatus").first.text);
    } else {
      coachNameElements = participant.findAllElements("User");
    }

    if (coachNameElements.isEmpty) {
      coachName = "AI";
    } else {
      coachName = coachNameElements.first.text;
    }


    var nameColumn = Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$teamName', style: TextStyle(fontSize: 20.0)),
          Padding(padding:EdgeInsets.only(left: 20),
              child: Text('$coachName',style: TextStyle(fontSize: 20.0))),
        ]);

    var child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            nameColumn,
          ]),
    );
    return child;
  }
}