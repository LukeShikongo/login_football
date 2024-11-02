import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TopScorerPage extends StatefulWidget {
  const TopScorerPage({super.key});

  @override
  State<TopScorerPage> createState() => _TopScorerPageState();
}

class _TopScorerPageState extends State<TopScorerPage> {
  List<Map<String, dynamic>> playersGoals = [];

  @override
  void initState() {
    super.initState();
    fetchTopScorersFromFixtures();
  }

  // Fetch players and goals from the fixtures collection
  void fetchTopScorersFromFixtures() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('fixtures')
          .where('isCompleted', isEqualTo: true) // Get completed matches only
          .get();

      Map<String, int> goalCount = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> matchData = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> goalScorers = matchData['goalScorers'] ?? {};

        // Home team goal scorers
        List<dynamic> homeScorers = goalScorers['home'] ?? [];
        for (var scorer in homeScorers) {
          goalCount[scorer] = (goalCount[scorer] ?? 0) + 1;
        }

        // Away team goal scorers
        List<dynamic> awayScorers = goalScorers['away'] ?? [];
        for (var scorer in awayScorers) {
          goalCount[scorer] = (goalCount[scorer] ?? 0) + 1;
        }
      }

      // Convert the goal count map to a list of players and goals
      List<Map<String, dynamic>> playersData = goalCount.entries.map((entry) {
        return {'name': entry.key, 'goals': entry.value};
      }).toList();

      // Sort players by the number of goals in descending order
      playersData.sort((a, b) => b['goals'].compareTo(a['goals']));

      setState(() {
        playersGoals = playersData;  // Use playersData directly
      });
    } catch (e) {
      print('Error fetching top scorers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: playersGoals.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: playersGoals.length,
              itemBuilder: (context, index) {
                final player = playersGoals[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      player['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    trailing: Text(
                      '${player['goals']} goals',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
