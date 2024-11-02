import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nam_football/services/database.dart';

class LogstandData extends StatefulWidget {
  const LogstandData({super.key});

  @override
  State<LogstandData> createState() => _LogstandDataState();
}

class _LogstandDataState extends State<LogstandData> {
  List<Map<String, dynamic>> teamData = [];

  @override
  void initState() {
    super.initState();
    // Fetch initial team data from Firestore
    fetchTeamData();

    // Listen to real-time updates for match results
    DatabaseMethods().matchCollection.snapshots().listen((snapshot) {
      updateLogStandings(snapshot);
    });
  }

  // Fetch team data from Firebase
  void fetchTeamData() {
    DatabaseMethods().teamCollection.snapshots().listen((snapshot) {
      setState(() {
        teamData = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    });
  }

  // This function will reset and update the log standings
  void updateLogStandings(QuerySnapshot matchSnapshot) {
    try {
      resetTeamStats();

      // Loop through each match result and calculate standings
      for (var matchDoc in matchSnapshot.docs) {
        Map<String, dynamic> matchData = matchDoc.data() as Map<String, dynamic>;

        String homeTeam = matchData['homeTeam'];
        String awayTeam = matchData['awayTeam'];
        int homeScore = matchData['homeScore'];
        int awayScore = matchData['awayScore'];

        // Update team stats for both home and away teams based on exact name matching
        _updateTeamStatsByExactMatch(homeTeam, homeScore, awayScore);
        _updateTeamStatsByExactMatch(awayTeam, awayScore, homeScore);
      }

      // After recalculating, sort teams by points and goal difference
      setState(() {
        teamData.sort((a, b) {
          int pointComparison = (b['Points'] ?? 0).compareTo(a['Points'] ?? 0);
          if (pointComparison != 0) return pointComparison;
          return (b['Goal difference'] ?? 0).compareTo(a['Goal difference'] ?? 0);
        });
      });
    } catch (e) {
      print('Error updating standings: $e');
    }
  }

  void resetTeamStats() {
    for (var team in teamData) {
      team['Match played'] = 0;
      team['Match won'] = 0;
      team['Match drawn'] = 0;
      team['Match lost'] = 0;
      team['Goal difference'] = 0;
      team['Points'] = 0;
    }
  }

  Future<void> _updateTeamStatsByExactMatch(String teamName, int goalsFor, int goalsAgainst) async {
    try {
      Map<String, dynamic>? team = teamData.firstWhere(
          (team) => team['Team Name'].toLowerCase() == teamName.toLowerCase(),
          orElse: () => {});

      if (team.isNotEmpty) {
        team['Match played'] = (team['Match played'] ?? 0) + 1;
        if (goalsFor > goalsAgainst) {
          team['Match won'] = (team['Match won'] ?? 0) + 1;
          team['Points'] = (team['Points'] ?? 0) + 3;
        } else if (goalsFor == goalsAgainst) {
          team['Match drawn'] = (team['Match drawn'] ?? 0) + 1;
          team['Points'] = (team['Points'] ?? 0) + 1;
        } else {
          team['Match lost'] = (team['Match lost'] ?? 0) + 1;
        }
        team['Goal difference'] = (team['Goal difference'] ?? 0) + (goalsFor - goalsAgainst);

        // Update Firestore with new stats
        await DatabaseMethods().teamCollection
            .doc(team['Team Name'])
            .update({
              'Match played': team['Match played'],
              'Match won': team['Match won'],
              'Match drawn': team['Match drawn'],
              'Match lost': team['Match lost'],
              'Goal difference': team['Goal difference'],
              'Points': team['Points'],
            });
      }
    } catch (e) {
      print('Error updating team stats for $teamName: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: teamData.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.warning, size: 64, color: Colors.orange),
                  SizedBox(height: 20),
                  Text(
                    'No data available',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('')),
                    DataColumn(label: Text('Team Name')),
                    DataColumn(label: Text('MP')),
                    DataColumn(label: Text('W')),
                    DataColumn(label: Text('D')),
                    DataColumn(label: Text('L')),
                    DataColumn(label: Text('GD')),
                    DataColumn(label: Text('Pts')),
                  ],
                  rows: teamData.asMap().entries.map(
                    (entry) {
                      int index = entry.key;
                      Map<String, dynamic> team = entry.value;

                      return DataRow(cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(Text(team['Team Name'] ?? '')),
                        DataCell(Text(team['Match played']?.toString() ?? '')),
                        DataCell(Text(team['Match won']?.toString() ?? '')),
                        DataCell(Text(team['Match drawn']?.toString() ?? '')),
                        DataCell(Text(team['Match lost']?.toString() ?? '')),
                        DataCell(Text(team['Goal difference']?.toString() ?? '')),
                        DataCell(Text(team['Points']?.toString() ?? '')),
                      ]);
                    },
                  ).toList(),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          QuerySnapshot snapshot = await DatabaseMethods().matchCollection.get();
          updateLogStandings(snapshot);
        },
        child: const Icon(Icons.update),
      ),
    );
  }
}
