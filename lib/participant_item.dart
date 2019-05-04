import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

class ParticipantItem extends StatelessWidget {
  final XmlElement participant;

  const ParticipantItem({Key key, this.participant}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    var status = int.parse(participant.findElements("IdTeamCompetitionStatus").first.text);
    var teamName;
    var coachName;

    Function onPressed;

    var nameColumn = Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$teamName', style: TextStyle(fontSize: 20.0)),
          Padding(padding:EdgeInsets.only(left: 20),
              child: Text('$coachName',style: TextStyle(fontSize: 20.0)))

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
    return FlatButton(child: child, onPressed: onPressed,);
  }
}