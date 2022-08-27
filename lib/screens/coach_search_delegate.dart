import 'dart:io';

import 'package:BB2Admin/bb2admin.dart';
import 'package:bb2_mobile_app/common_widgets/participant_item.dart';
import 'package:bb2_mobile_app/common_widgets/suggestions_list.dart';
import 'package:bb2_mobile_app/themes/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

class CoachAndTeam {
  CoachAndTeam(this.coachId, this.teamId);
  final String coachId;
  final String teamId;
}

class CoachSearchDelegate extends SearchDelegate<CoachAndTeam?> {
  var currentQuery = "";
  var isLoading = false;
  SharedPreferences? prefs;
  List<String> teamSuggestions = [];
  List<String> coachSuggestions = [];

  var suggestions = ["[ADMIN]"];

  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      primaryColor: AppTheme.getBackgroundColor(),
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryTextTheme: theme.textTheme,
    );
  }

  late Widget coachSearch;
  TextEditingController coachController = TextEditingController();

  CoachSearchDelegate(BuildContext context) {
    var theme = appBarTheme(context);
    SharedPreferences.getInstance().then((prefs) {
      this.prefs = prefs;
      teamSuggestions =
          prefs.getStringList("search_team_query_suggestions") ?? [];
      coachSuggestions =
          prefs.getStringList("search_coach_query_suggestions") ?? [];
    });
    coachSearch = Padding(
      padding: EdgeInsets.only(left: 20),
      child: TextField(
        style: theme.textTheme.headline6,
        controller: coachController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Coach",
          hintStyle: theme.inputDecorationTheme.hintStyle,
        ),
        onChanged: (coachQuery) {
          triggerRerender();
        },
        onSubmitted: (String _) {
          showResults(context);
        },
        textInputAction: TextInputAction.search,
      ),
    );
  }

  void triggerRerender() {
    var temp = query;
    query = "";
    Future.delayed(new Duration(milliseconds: 1), () {
      query = temp;
    });
  }

  void sendTicketToCoach(BuildContext context, XmlElement data, Widget cell) {
    var coachId = data.findAllElements("IdUser").first.text;
    var teamId = data
        .findAllElements("RowTeam")
        .first
        .findElements("ID")
        .first
        .firstChild!
        .text;
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Are you sure wish to send this team a ticket?"),
            content: SingleChildScrollView(child: cell),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Send'),
                onPressed: () {
                  close(context, CoachAndTeam(coachId, teamId));
                },
              ),
            ],
          );
        });
  }

  void toggleFavoriteQuery() async {
    var add = true;
    for (var i = 0; i < teamSuggestions.length; ++i) {
      if (query == teamSuggestions[i] &&
          coachController.text == coachSuggestions[i]) {
        // Remove
        add = false;
        teamSuggestions.removeAt(i);
        coachSuggestions.removeAt(i);
        break;
      }
    }
    if (add) {
      teamSuggestions += [query];
      coachSuggestions += [coachController.text];
    }
    prefs?.setStringList("search_team_query_suggestions", teamSuggestions);
    prefs?.setStringList("search_coach_query_suggestions", coachSuggestions);
    triggerRerender();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    List<Widget> actions = [];

    if (query.length > 1) {
      actions += [
        IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              query = "";
              showSuggestions(context);
            }),
      ];
    }
    if (Platform.isIOS)
      actions += [
        CupertinoButton(
          child: Text("Close"),
          onPressed: () => close(context, null),
        )
      ];

    return actions;
  }

  @override
  Widget buildLeading(BuildContext context) {
    if (query.length > 2 || coachController.text.length > 2) {
      var starIcon = Icon(Icons.star_border, color: Colors.amber);
      if (teamSuggestions.contains(query) &&
          coachSuggestions.contains(coachController.text)) {
        starIcon = Icon(Icons.star, color: Colors.amber);
      }
      return TextButton(
        child: starIcon,
        onPressed: toggleFavoriteQuery,
      );
    } else {
      return Icon(Icons.search);
    }
  }

  @override
  Widget buildSuggestions(BuildContext context) => Container(
      color: AppTheme.getBackgroundColor(),
      child: Column(
        children: <Widget>[
          coachSearch,
          Container(color: Theme.of(context).dividerColor, height: 0.5),
          Expanded(child: SuggestionList(
            onTapped: (team, coach) {
              query = team;
              coachController.text = coach;
              showResults(context);
            },
          ))
        ],
      ));

  @override
  Widget buildResults(BuildContext context) {
    Widget body = Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(),
    );
    if (query.length > 2 || coachController.text.length > 2) {
      body = FutureBuilder<Iterable<XmlElement>>(
          future:
              BB2Admin.defaultManager.searchTeam(query, coachController.text),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var listView = ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(),
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    var data = snapshot.data!.elementAt(index);
                    Widget participantView = ParticipantItem(participant: data);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        participantView,
                        IconButton(
                            icon: Icon(Icons.mail),
                            padding: EdgeInsets.only(right: 10),
                            color: Colors.red,
                            onPressed: () => sendTicketToCoach(
                                context, data, participantView))
                      ],
                    );
                  });
              return listView;
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Searching for teams...',
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );
            }
          });
    }
    return Container(
        color: AppTheme.getBackgroundColor(),
        child: Column(
          children: <Widget>[
            coachSearch,
            Container(color: Theme.of(context).dividerColor, height: 0.5),
            Expanded(child: body)
          ],
        ));
  }
}
