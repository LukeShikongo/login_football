import 'package:flutter/material.dart';
import 'package:nam_football/services/database.dart';

class EditMatchForm extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> matchData;

  const EditMatchForm({
    Key? key,
    required this.matchId,
    required this.matchData,
  }) : super(key: key);

  @override
  _EditMatchFormState createState() => _EditMatchFormState();
}

class _EditMatchFormState extends State<EditMatchForm> {
  late TextEditingController homeTeamController;
  late TextEditingController awayTeamController;
  late TextEditingController dateController;
  late TextEditingController timeController;


  @override
  void initState() {
    super.initState();
    homeTeamController = TextEditingController(text: widget.matchData['homeTeam']);
    awayTeamController = TextEditingController(text: widget.matchData['awayTeam']);
    dateController = TextEditingController(text: widget.matchData['date']);
    timeController = TextEditingController(text: widget.matchData['time']);
  }

  // Update match data
  void updateMatch() async {
    Map<String, dynamic> updatedMatchData = {
      'homeTeam': homeTeamController.text,
      'awayTeam': awayTeamController.text,
      'date': dateController.text,
      'time': timeController.text,
    };
    await DatabaseMethods().updateMatch(widget.matchId, updatedMatchData);
    Navigator.pop(context); // Go back after saving
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Match'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: homeTeamController,
              decoration: const InputDecoration(labelText: 'Home Team'),
            ),
            TextField(
              controller: awayTeamController,
              decoration: const InputDecoration(labelText: 'Away Team'),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateMatch,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
