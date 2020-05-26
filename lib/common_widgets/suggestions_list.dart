
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuggestionList extends StatefulWidget {
  SuggestionList({Key key, this.onTapped})
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
    var teamMames = prefs.getStringList("search_team_query_suggestions");
    var coachNames = prefs.getStringList("search_coach_query_suggestions");
    suggestions = [];
    for (var i = 0; i < teamMames.length; ++i) {
      suggestions += [[teamMames[i], coachNames[i]]];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        itemCount: suggestions.length,
        separatorBuilder: (BuildContext context, int index) =>
            Container(color: Theme.of(context).dividerColor, height: 0.5),
        itemBuilder: (BuildContext context, int index) {
          var team = suggestions[index][0];
          var coach = suggestions[index][1];
          return new ListTile(
            title: Text(team),
            leading: Icon(Icons.star, color: Colors.amber),
            subtitle: Text(coach),
            onTap: () {
              widget.onTapped(team, coach);
              pullSuggestions();
            },
          );
        });
  }
}