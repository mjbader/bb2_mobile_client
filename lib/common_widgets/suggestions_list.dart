
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionList extends StatefulWidget {
  SuggestionList({Key? key, required this.onTapped})
      : super(key: key);
  final Function onTapped;


  @override
  _SuggestionListState createState() => _SuggestionListState();
}

class _SuggestionListState extends State<SuggestionList> {
  List<List<String>> suggestions = [];

  @override
  void initState() {
    super.initState();
    pullSuggestions();
  }

  void pullSuggestions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var teamNames = prefs.getStringList("search_team_query_suggestions");
    var coachNames = prefs.getStringList("search_coach_query_suggestions");
    suggestions = [];
    if (teamNames != null && coachNames != null) {
      for (var i = 0; i < teamNames.length; ++i) {
        suggestions += [[teamNames[i], coachNames[i]]];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: suggestions.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          var team = suggestions[index][0];
          var coach = suggestions[index][1];
          return new ListTile(
            title: Text(team, style: Theme.of(context).textTheme.subtitle1),
            leading: Icon(Icons.star, color: Colors.amber),
            subtitle: Text(coach, style: Theme.of(context).textTheme.subtitle2),
            onTap: () {
              widget.onTapped(team, coach);
              pullSuggestions();
            },
          );
        });
  }
}