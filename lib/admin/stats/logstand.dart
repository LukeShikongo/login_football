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
    fetchTeamData();
  }

  // Fetch team data from Firebase Firestore
  void fetchTeamData() {
    DatabaseMethods().teamCollection.snapshots().listen((snapshot) {
      setState(() {
        teamData = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    });
  }

  // Helper function to reset team stats
  void resetTeamStats() {
    for (var team in teamData) {
      team['Goal difference'] = 0;
      team['Points'] = 0;
    }
  }

  // Update the standings only for matches with valid results
  void updateLogStandings(QuerySnapshot matchSnapshot) {
    resetTeamStats(); // Reset stats before processing new matches

    for (var matchDoc in matchSnapshot.docs) {
      Map<String, dynamic> matchData = matchDoc.data() as Map<String, dynamic>;

      String homeTeam = matchData['homeTeam'];
      String awayTeam = matchData['awayTeam'];
      int? homeScore = matchData['homeScore'];
      int? awayScore = matchData['awayScore'];

      if (homeScore == null || awayScore == null) continue; // Skip incomplete matches

      // Update stats for both home and away teams
      _updateTeamStatsByExactMatch(homeTeam, homeScore, awayScore);
      _updateTeamStatsByExactMatch(awayTeam, awayScore, homeScore);
    }

    setState(() {
      // Sort teams by points, then alphabetically if points are equal
      teamData.sort((a, b) {
        int pointComparison = (b['Points'] ?? 0).compareTo(a['Points'] ?? 0);
        if (pointComparison != 0) return pointComparison;
        return (a['Team Name'] ?? '').compareTo(b['Team Name'] ?? '');
      });
    });
  }

  // Update individual team stats
  Future<void> _updateTeamStatsByExactMatch(
      String teamName, int goalsFor, int goalsAgainst) async {
    try {
      Map<String, dynamic>? team = teamData.firstWhere(
          (team) => team['Team Name'].toLowerCase() == teamName.toLowerCase(),
          orElse: () => {});

      if (team.isNotEmpty) {
        if (goalsFor > goalsAgainst) {
          team['Points'] = (team['Points'] ?? 0) + 3;
        } else if (goalsFor == goalsAgainst) {
          team['Points'] = (team['Points'] ?? 0) + 1;
        }
        team['Goal difference'] =
            (team['Goal difference'] ?? 0) + (goalsFor - goalsAgainst);

        // Update Firestore with new stats
        await DatabaseMethods().teamCollection
            .doc(team['Team Name'])
            .update({
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
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseMethods().teamCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error fetching data'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No data available'),
            );
          }

          // Update local teamData with fetched data
          teamData = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Position')),
                DataColumn(label: Text('Team Name')),
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
                    DataCell(Text(team['Goal difference']?.toString() ?? '')),
                    DataCell(Text(team['Points']?.toString() ?? '')),
                  ]);
                },
              ).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          QuerySnapshot snapshot =
              await DatabaseMethods().matchCollection.get();
          updateLogStandings(snapshot);
        },
        child: const Icon(Icons.update),
      ),
    );
  }
}
