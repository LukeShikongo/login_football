import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nam_football/admin/matches/editmatch.dart';
import 'package:nam_football/admin/matches/editmatchresults.dart';
import 'package:nam_football/services/database.dart';
import 'package:intl/intl.dart';

class MatchDatas extends StatefulWidget {
  const MatchDatas({super.key});

  @override
  State<MatchDatas> createState() => _MatchDatasState();
}

class _MatchDatasState extends State<MatchDatas> {
  List<Map<String, dynamic>> matchData = [];
  String errorMessage = '';
  bool isLoading = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchMatchData();

    // Timer to update elapsed minutes every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {}); // Update UI every minute
      updateScoresForOngoingMatches(); // Check if any match has started
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel timer when widget is disposed
    super.dispose();
  }

  // Fetch match data from the database
  void fetchMatchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedData =
          await DatabaseMethods().getAllMatchDetails();

      fetchedData.sort((a, b) {
        DateTime dateA = _safeParseDate(a['date'] ?? '');
        DateTime dateB = _safeParseDate(b['date'] ?? '');
        TimeOfDay timeA = _parseTime(a['time'] ?? '00:00');
        TimeOfDay timeB = _parseTime(b['time'] ?? '00:00');

        int dateComparison = dateA.compareTo(dateB);
        if (dateComparison != 0) return dateComparison;

        return _compareTimes(timeA, timeB);
      });

      setState(() {
        matchData = fetchedData;
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load match data: $e';
      });
      print('Error fetching match data: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Method to delete match data
  void deleteMatchData(String matchId) async {
    try {
      await DatabaseMethods().deleteMatch(matchId); // Delete from database
      setState(() {
        matchData.removeWhere((match) => match['id'] == matchId); // Remove from local list
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error deleting match: $e';
      });
      print('Error deleting match: $e');
    }
  }

  // Helper function to safely parse date
  DateTime _safeParseDate(String? dateStr) {
    try {
      if (dateStr == null || dateStr.isEmpty) {
        return DateTime(1970, 1, 1);
      }
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime(1970, 1, 1);
    }
  }

  // Helper function to parse time
  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  // Helper function to compare TimeOfDay
  int _compareTimes(TimeOfDay timeA, TimeOfDay timeB) {
    if (timeA.hour != timeB.hour) {
      return timeA.hour.compareTo(timeB.hour);
    } else {
      return timeA.minute.compareTo(timeB.minute);
    }
  }

  // Calculate elapsed minutes since match start
  int calculateElapsedMinutes(String date, String time) {
    DateTime matchDateTime = DateTime.parse(date).add(
      Duration(
        hours: int.parse(time.split(":")[0]),
        minutes: int.parse(time.split(":")[1]),
      ),
    );
    return DateTime.now().difference(matchDateTime).inMinutes;
  }

  // Check if match should start with 0-0 score
  void updateScoresForOngoingMatches() {
    for (var match in matchData) {
      if (shouldSetInitialScore(match)) {
        setMatchScore(match['id'], 0, 0); // Set initial score to 0-0
      }
    }
  }

  // Determine if match should have initial score set
  bool shouldSetInitialScore(Map<String, dynamic> match) {
    String date = match['date'] ?? '';
    String time = match['time'] ?? '00:00';
    DateTime matchDateTime = DateTime.parse(date).add(
      Duration(
        hours: int.parse(time.split(":")[0]),
        minutes: int.parse(time.split(":")[1]),
      ),
    );
    bool hasStarted = DateTime.now().isAfter(matchDateTime);
    bool scoreNotSet = (match['homeScore'] == null && match['awayScore'] == null) ||
                       (match['homeScore'] == '-' && match['awayScore'] == '-');
    return hasStarted && scoreNotSet;
  }

  // Set match score in the database
  void setMatchScore(String matchId, int homeScore, int awayScore) async {
    await DatabaseMethods().updateMatchScore(matchId, homeScore, awayScore);
    setState(() {
      matchData = matchData.map((match) {
        if (match['id'] == matchId) {
          match['homeScore'] = homeScore.toString();
          match['awayScore'] = awayScore.toString();
        }
        return match;
      }).toList();
    });
  }

  // Display match widgets grouped by date
  Widget buildMatchWidget(String date, List<Map<String, dynamic>> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the date
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            DateFormat('EEEE, dd MMM yyyy').format(
              _safeParseDate(date.isNotEmpty ? date : '1970-01-01'),
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),

        // Loop through the matches for the day
        ...matches.map((match) {
          final homeTeam = match['homeTeam'] ?? 'Home Team';
          final awayTeam = match['awayTeam'] ?? 'Away Team';
          final time = match['time'] ?? 'Unknown Time';
          final homeScore = match['homeScore'] ?? '-';
          final awayScore = match['awayScore'] ?? '-';
          final goalScorers = match['goalScorers'] ?? {'home': [], 'away': []};
          final isCompleted = match['isCompleted'] ?? false;

          // Check if the match has started
          bool hasStarted = DateTime.now().isAfter(
            DateTime.parse(date).add(
              Duration(
                hours: int.parse(time.split(":")[0]),
                minutes: int.parse(time.split(":")[1]),
              ),
            ),
          );

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Teams and Time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(homeTeam, style: const TextStyle(fontSize: 18)),
                      Text(time, style: const TextStyle(fontSize: 18)),
                      Text(awayTeam, style: const TextStyle(fontSize: 18)),
                    ],
                  ),

                  if (hasStarted && !isCompleted)
                    Text(
                      '${calculateElapsedMinutes(date, time)} "',
                      style: const TextStyle(fontSize: 16, color: Colors.orange),
                    ),

                  if (isCompleted || hasStarted)
                    Column(
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          '$homeScore - $awayScore',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.green),
                        ),
                        const SizedBox(height: 5),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$homeTeam: ${goalScorers['home'].join(', ')}'),
                            Text('$awayTeam: ${goalScorers['away'].join(', ')}'),
                          ],
                        ),
                      ],
                    ),

                  const Divider(thickness: 1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMatchForm(
                                matchId: match['id'],
                                matchData: match,
                              ),
                            ),
                          ).then((_) => fetchMatchData());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        onPressed: () {
                          deleteMatchData(match['id']);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.sports_soccer),
                        color: Colors.orange,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMatchResultsForm(
                                matchId: match['id'],
                                matchData: match,
                              ),
                            ),
                          ).then((_) => fetchMatchData());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> matchesByDate = {};
    for (var match in matchData) {
      String date = match['date'] ?? 'Unknown Date';
      if (!matchesByDate.containsKey(date)) {
        matchesByDate[date] = [];
      }
      matchesByDate[date]!.add(match);
    }

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matchData.isEmpty
              ? errorMessage.isNotEmpty
                  ? Center(child: Text(errorMessage))
                  : const Center(child: Text("No match data available."))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: matchesByDate.entries.map((entry) {
                    String date = entry.key;
                    List<Map<String, dynamic>> matches = entry.value;
                    return buildMatchWidget(date, matches);
                  }).toList(),
                ),
    );
  }
}
