import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nam_football/admin/teams/player_form.dart';

class PlayerList extends StatelessWidget {
  const PlayerList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: const Text(
          'Squad List',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        backgroundColor: Colors.blue, // Changed AppBar color
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Team squad').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No players found.'));
          }

          // Process the player data
          final players = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>?; // Safely cast the data
            return Player(
              name: data?['name'] as String? ?? 'Unknown',   // Provide default if 'name' is null
              position: data?['position'] as String? ?? 'Unknown', // Provide default if 'position' is null
              flagUrl: data != null && data.containsKey('flagUrl') ? data['flagUrl'] as String? : null, // Check for 'flagUrl' field
              number: data != null && data.containsKey('number') ? data['number'] as int? : null,       // Check for 'number' field
            );
          }).toList();

          // Sort players by position
          players.sort((a, b) {
            return _positionOrder(a.position).compareTo(_positionOrder(b.position));
          });

          // Group players by position
          Map<String, List<Player>> groupedPlayers = {};
          for (var player in players) {
            if (!groupedPlayers.containsKey(player.position)) {
              groupedPlayers[player.position] = [];
            }
            groupedPlayers[player.position]!.add(player);
          }

          return ListView(
            children: groupedPlayers.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      entry.key,  // Position as heading (e.g., Goalkeepers)
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Column(
                    children: entry.value.map((player) {
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person, color: Colors.white),  // Head icon instead of image
                          backgroundColor: Colors.blue, // Changed background color of avatar
                        ),
                        title: Text(player.name),
                        subtitle: Row(
                          children: [
                            if (player.flagUrl != null)
                              Image.network(
                                player.flagUrl!,
                                width: 24,
                                height: 24,
                              ),
                            const SizedBox(width: 8),
                            Text(player.position),
                          ],
                        ),
                        trailing: player.number != null
                            ? Text(player.number.toString())
                            : null,  // No markers/icons, only number if available
                      );
                    }).toList(),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add player navigation logic here
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BulkPlayerForm()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper method to determine position order
  int _positionOrder(String position) {
    switch (position) {
      case 'Goalkeeper':
        return 1;
      case 'Defender':
        return 2;
      case 'Midfielder':
        return 3;
      case 'Attacker':
        return 4;
      default:
        return 5; // For any unknown positions
    }
  }
}

// Model class to hold player data
class Player {
  final String name;
  final String position;
  final String? flagUrl;
  final int? number;

  Player({
    required this.name,
    required this.position,
    this.flagUrl,
    this.number,
  });
}
