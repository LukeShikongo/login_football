import 'package:flutter/material.dart';
import 'package:nam_football/services/database.dart';
import 'package:intl/intl.dart'; // Add intl package for date formatting

class MatchDatasUsr extends StatefulWidget {
  const MatchDatasUsr({super.key});

  @override
  State<MatchDatasUsr> createState() => _MatchDatasUsrState();
}

class _MatchDatasUsrState extends State<MatchDatasUsr> {
  List<Map<String, dynamic>> matchData = [];
  String errorMessage = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMatchData();
  }

  // Fetch match data from the database
  void fetchMatchData() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Map<String, dynamic>> fetchedData =
          await DatabaseMethods().getAllMatchDetails();

      // Debug: print fetched data
      print('Fetched match data: $fetchedData');

      // Sort matches by date and time
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

  // Helper function to safely parse date
  DateTime _safeParseDate(String? dateStr) {
    try {
      if (dateStr == null || dateStr.isEmpty) {
        print('Empty or null date string detected.');
        return DateTime(1970, 1, 1);
      }

      final parsedDate = DateTime.parse(dateStr);
      print('Parsed date: $parsedDate');
      return parsedDate;
    } catch (e) {
      print('Failed to parse date: $dateStr. Error: $e');
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

                  if (isCompleted)
                    Column(
                      children: [
                        const SizedBox(height: 5),
                        Text(
                          '$homeScore - $awayScore',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
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
