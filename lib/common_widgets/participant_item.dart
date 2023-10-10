import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class ParticipantItem extends StatelessWidget {
  final XmlElement participant;

  const ParticipantItem({Key? key, required this.participant}) : super(key:key);

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
    } else {
      coachNameElements = participant.findAllElements("User");
    }

    if (coachNameElements.isEmpty) {
      coachName = "AI";
    } else {
      coachName = coachNameElements.first.text;
    }

    var logoFile = participant.findAllElements("RowTeam").first.findElements('Logo');
    var logoUrl;
    if (logoFile.isNotEmpty) {
      logoUrl = 'https://cdn.rebbl.net/images/logo/logo_${logoFile.first.text.toLowerCase()}.png';
    }


    var nameColumn = Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$teamName', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
          Padding(padding:EdgeInsets.only(left: 20),
              child: Text('$coachName',style: TextStyle(fontSize: 16.0))),
        ]);

    var child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (logoUrl != null)
              Image.network(
                logoUrl,
                frameBuilder: (context, widget, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return CircularProgressIndicator();
                  }
                  return widget;
                },
              ),
            Container(width: 10),
            nameColumn,
          ]),
    );
    return child;
  }
}