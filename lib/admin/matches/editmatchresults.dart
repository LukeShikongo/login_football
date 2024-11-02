import 'package:flutter/material.dart';
import 'package:nam_football/services/database.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import fluttertoast

class EditMatchResultsForm extends StatefulWidget {
  final String matchId;
  final Map<String, dynamic> matchData;

  const EditMatchResultsForm({
    Key? key,
    required this.matchId,
    required this.matchData,
  }) : super(key: key);

  @override
  _EditMatchResultsFormState createState() => _EditMatchResultsFormState();
}

class _EditMatchResultsFormState extends State<EditMatchResultsForm> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController homeScoreController = TextEditingController();
  TextEditingController awayScoreController = TextEditingController();
  TextEditingController homeScorersController = TextEditingController();
  TextEditingController awayScorersController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize match data with null checks and default values
    homeScoreController.text = widget.matchData['homeScore']?.toString() ?? '0'; // Defaults to '0' if null
    awayScoreController.text = widget.matchData['awayScore']?.toString() ?? '0'; // Defaults to '0' if null

    // Handle goal scorers safely, providing default values if null or empty
    final homeScorers = widget.matchData['goalScorers']?['home'] ?? [];
    final awayScorers = widget.matchData['goalScorers']?['away'] ?? [];
  
    homeScorersController.text = homeScorers.isNotEmpty ? homeScorers.join(', ') : ''; // Show empty if no scorers
    awayScorersController.text = awayScorers.isNotEmpty ? awayScorers.join(', ') : ''; // Show empty if no scorers
  }

  @override
  void dispose() {
    homeScoreController.dispose();
    awayScoreController.dispose();
    homeScorersController.dispose();
    awayScorersController.dispose();
    super.dispose();
  }

  // Modify saveMatchResults to use widget.matchId and add toast + navigation
  Future<void> saveMatchResults() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Prepare updated data
        Map<String, dynamic> updatedMatchData = {
          'homeScore': int.tryParse(homeScoreController.text) ?? 0,
          'awayScore': int.tryParse(awayScoreController.text) ?? 0,
          'goalScorers': {
            'home': homeScorersController.text.isNotEmpty
                ? homeScorersController.text.split(',').map((s) => s.trim()).toList()
                : [],
            'away': awayScorersController.text.isNotEmpty
                ? awayScorersController.text.split(',').map((s) => s.trim()).toList()
                : [],
          },
          'isCompleted': true, // Mark match as completed after results are saved
        };

        // Use the widget.matchId passed to this form
        await DatabaseMethods().updateMatch(widget.matchId, updatedMatchData);

        // Show success message using Fluttertoast
        Fluttertoast.showToast(
          msg: "Match result updated successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );

        // Navigate back to the fixture page
        Navigator.pop(context);
      } catch (error) {
        print('Error updating match result: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Match Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                '${widget.matchData['homeTeam']} - ${widget.matchData['awayTeam']}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Home Team Score Input
              TextFormField(
                controller: homeScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Home Team Score',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter home team score';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Away Team Score Input
              TextFormField(
                controller: awayScoreController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Away Team Score',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter away team score';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Home Team Goal Scorers Input (Optional)
              TextFormField(
                controller: homeScorersController,
                decoration: const InputDecoration(
                  labelText: 'Home Team Goal Scorers (comma separated)',
                  border: OutlineInputBorder(),
                ),
                // Make goal scorers input optional
                validator: (value) {
                  return null; // No validation needed for optional input
                },
              ),
              const SizedBox(height: 20),

              // Away Team Goal Scorers Input (Optional)
              TextFormField(
                controller: awayScorersController,
                decoration: const InputDecoration(
                  labelText: 'Away Team Goal Scorers (comma separated)',
                  border: OutlineInputBorder(),
                ),
                // Make goal scorers input optional
                validator: (value) {
                  return null; // No validation needed for optional input
                },
              ),
              const SizedBox(height: 30),

              // Save Button
              ElevatedButton(
                onPressed: saveMatchResults,
                child: const Text('Save Results'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
