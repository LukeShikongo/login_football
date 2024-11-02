import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nam_football/services/database.dart';

// Define a Team model class
class Team {
  String name;
  int goalDifference;
  int points;
  int mp;

  Team({
    required this.name,
    this.goalDifference = 0,
    this.points = 0,
    this.mp = 0,
  });
}

class LogstandTableUsr extends StatefulWidget {
  const LogstandTableUsr({super.key});

  @override
  State<LogstandTableUsr> createState() => _LogstandTableUsrState();
}

class _LogstandTableUsrState extends State<LogstandTableUsr> {
  List<Team> teams = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchTeamData();
    DatabaseMethods().matchCollection.snapshots().listen(updateLogStandings);
    fetchAndUpdateMatchResults();
  }

  Future<void> fetchTeamData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final snapshot = await DatabaseMethods().teamCollection.get();
      setState(() {
        teams = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Team(
            name: data['Team Name'] ?? 'Unknown',
            goalDifference: data['Goal difference'] ?? 0,
            points: data['Points'] ?? 0,
            mp: data['MP'] ?? 0,
          );
        }).toList();
        sortTeams();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching team data: $e';
      });
    }
  }

  Future<void> fetchAndUpdateMatchResults() async {
    try {
      final snapshot = await DatabaseMethods().fixtureCollection.get();
      for (var matchDoc in snapshot.docs) {
        Map<String, dynamic> matchData = matchDoc.data() as Map<String, dynamic>;

        // Skip matches without valid scores
        if (matchData['homeScore'] == null || matchData['awayScore'] == null) {
          continue;
        }

        String homeTeam = matchData['homeTeam'];
        String awayTeam = matchData['awayTeam'];
        int homeScore = matchData['homeScore'];
        int awayScore = matchData['awayScore'];

        _updateTeamStats(homeTeam, homeScore, awayScore);
        _updateTeamStats(awayTeam, awayScore, homeScore);
      }
      setState(() {
        sortTeams();
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error fetching match results: $e';
      });
    }
  }

  void _updateTeamStats(String teamName, int goalsFor, int goalsAgainst) {
    final team = teams.firstWhere((team) => team.name == teamName, orElse: () {
      final newTeam = Team(name: teamName);
      teams.add(newTeam);
      return newTeam;
    });

    team.goalDifference += (goalsFor - goalsAgainst);

    // Increment matches played only if scores are valid
    team.mp += 1;

    if (goalsFor > goalsAgainst) {
      team.points += 3;
    } else if (goalsFor == goalsAgainst) {
      team.points += 1;
    }
  }

  void sortTeams() {
    teams.sort((a, b) {
      int pointComparison = b.points.compareTo(a.points);
      if (pointComparison != 0) return pointComparison;
      return a.name.compareTo(b.name);
    });
  }

  void updateLogStandings(QuerySnapshot matchSnapshot) {
    try {
      resetTeamStats();
      for (var matchDoc in matchSnapshot.docs) {
        Map<String, dynamic> matchData = matchDoc.data() as Map<String, dynamic>;

        // Skip matches without valid scores
        if (matchData['homeScore'] == null || matchData['awayScore'] == null) {
          continue;
        }

        String homeTeam = matchData['homeTeam'];
        String awayTeam = matchData['awayTeam'];
        int homeScore = matchData['homeScore'];
        int awayScore = matchData['awayScore'];

        _updateTeamStats(homeTeam, homeScore, awayScore);
        _updateTeamStats(awayTeam, awayScore, homeScore);
      }
      setState(() {
        sortTeams();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating standings: $e')),
      );
    }
  }

  void resetTeamStats() {
    for (var team in teams) {
      team.goalDifference = 0;
      team.points = 0;
      team.mp = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: teams.isEmpty
          ? Center(
              child: Text(
                errorMessage.isNotEmpty ? errorMessage : 'No data available',
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                child: DataTable(
                  columns: [
                    DataColumn(label: _buildHeader('Pos')),
                    DataColumn(label: _buildHeader('Team Name')),
                    DataColumn(label: _buildHeader('MP')), // Matches Played
                    DataColumn(label: _buildHeader('GD')), // Goal Difference
                    DataColumn(label: _buildHeader('Pts')), // Points
                  ],
                  rows: teams.asMap().entries.map((entry) {
                    int index = entry.key;
                    Team team = entry.value;

                    return DataRow(cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(SizedBox(
                        width: 100,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(team.name, style: const TextStyle(fontSize: 16)),
                        ),
                      )),
                      DataCell(Text(team.mp.toString(), style: const TextStyle(fontSize: 16))),
                      DataCell(Text(team.goalDifference.toString(), style: const TextStyle(fontSize: 16))),
                      DataCell(Text(team.points.toString(), style: const TextStyle(fontSize: 16))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchTeamData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data refreshed!')),
          );
        },
        child: const Icon(Icons.update),
      ),
    );
  }

  Widget _buildHeader(String text) {
    return SizedBox(
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
