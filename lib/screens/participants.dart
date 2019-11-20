import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:xml/xml.dart';
import 'package:bb2_mobile_app/common_widgets/participant_list.dart';

class ParticipantsScreen extends StatelessWidget {
  final List<XmlElement> participants;
  final String title;
  final String compId;
  final int maxTeams;
  final Function onKick;

  const ParticipantsScreen({Key key, this.title, this.participants, this.compId, this.maxTeams, this.onKick}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    var body = ParticipantList(compId: compId, participants: participants, maxTeams: maxTeams, onKick: this.onKick,);

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(this.title),
      ),
      body: SafeArea(child: body, bottom: false,),
    );
  }
}