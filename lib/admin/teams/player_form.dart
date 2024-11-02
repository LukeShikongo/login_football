import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nam_football/admin/teams/payer_list.dart';
import 'package:nam_football/services/database.dart';

class BulkPlayerForm extends StatefulWidget {
  const BulkPlayerForm({super.key});

  @override
  State<BulkPlayerForm> createState() => _BulkPlayerFormState();
}

class _BulkPlayerFormState extends State<BulkPlayerForm> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseMethods _databaseMethods = DatabaseMethods(); // Instance of your database method

  // List to hold multiple player entries
  List<PlayerEntry> _players = [PlayerEntry()];
  List<String> _teams = []; // List to hold teams
  String? _selectedTeam; // Selected team
  bool _isLoadingTeams = true; // Loading flag for teams

  // List of player positions
  final List<String> _positions = [
    'Goalkeeper',
    'Defender',
    'Midfielder',
    'Attacker'
  ];

  @override
  void initState() {
    super.initState();
    _fetchTeams(); // Fetch the teams when the form is initialized
  }

  // Fetch the teams from Firestore's Team collection
  Future<void> _fetchTeams() async {
    try {
      final teamSnapshot = await FirebaseFirestore.instance.collection('Team').get();
      setState(() {
        _teams = teamSnapshot.docs.map((doc) => doc['name'] as String).toList();
        _isLoadingTeams = false; // Data fetched, set loading to false
      });
    } catch (e) {
      print('Error fetching teams: $e');
      setState(() {
        _isLoadingTeams = false; // Set loading to false even if there's an error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load teams!')),
      );
    }
  }

  // Save players to Firebase when form is submitted
  Future<void> _savePlayersToFirebase() async {
    try {
      for (var player in _players) {
        // Create a player data map
        Map<String, dynamic> playerData = {
          'name': player.nameController.text,
          'age': int.tryParse(player.ageController.text) ?? 0, // Player's age
          'position': player.selectedPosition,
          'team': _selectedTeam, // Add the selected team
        };

        // Generate a unique ID for each player document
        String playerId = FirebaseFirestore.instance.collection('Team squad').doc().id;

        // Save the player data in Firestore
        await _databaseMethods.addPlayer(playerData, playerId);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Players added successfully to the database!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PlayerList()), // Navigate to PlayerList
      );
    } catch (e) {
      print("Error saving players: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save players to the database!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Player Entry Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Team selection dropdown
              _isLoadingTeams
                  ? const CircularProgressIndicator() // Show a loading indicator while teams are being fetched
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Team',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedTeam,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTeam = newValue;
                        });
                      },
                      items: _teams.isNotEmpty
                          ? _teams.map<DropdownMenuItem<String>>((String team) {
                              return DropdownMenuItem<String>(
                                value: team,
                                child: Text(team),
                              );
                            }).toList()
                          : [], // Handle the case where no teams are fetched
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a team';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                      physics: const ScrollPhysics(), // Allow horizontal scrolling when content overflows
                      child: _buildPlayerForm(index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Add more player button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _players.add(PlayerEntry()); // Add new player entry
                  });
                },
                child: const Text('Add Another Player'),
              ),
              const SizedBox(height: 20),

              // Save players to Firebase button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Call the method to save players to Firebase
                    _savePlayersToFirebase();
                  }
                },
                child: const Text('Save Players to Database'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build each player entry form
  Widget _buildPlayerForm(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Player name input field
          SizedBox(
            width: 150, // Adjust width for horizontal scrolling
            child: TextFormField(
              controller: _players[index].nameController,
              decoration: const InputDecoration(
                labelText: 'Player Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the player\'s name';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 10),

          // Player age input field
          SizedBox(
            width: 100, // Adjust width for horizontal scrolling
            child: TextFormField(
              controller: _players[index].ageController,
              decoration: const InputDecoration(
                labelText: 'Player Age',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the player\'s age';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 10),

          // Player position dropdown
          SizedBox(
            width: 150, // Adjust width for horizontal scrolling
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(),
              ),
              value: _players[index].selectedPosition,
              onChanged: (newValue) {
                setState(() {
                  _players[index].selectedPosition = newValue;
                });
              },
              items: _positions.map<DropdownMenuItem<String>>((String position) {
                return DropdownMenuItem<String>(
                  value: position,
                  child: Text(position),
                );
              }).toList(),
              validator: (value) {
                if (value == null) {
                  return 'Please select a position';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 10),

          // Remove player button
          if (_players.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  _players.removeAt(index); // Remove the player entry
                });
              },
            ),
        ],
      ),
    );
  }
}

// Model class to hold player entry data
class PlayerEntry {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController(); // Age controller
  String? selectedPosition;
}
