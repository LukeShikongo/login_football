import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nam_football/admin/matches/fixtures.dart';
import 'package:nam_football/admin/matches/matchdata.dart';
import 'package:nam_football/admin/news/articleform.dart';
import 'package:nam_football/admin/news/newspage.dart';
import 'package:nam_football/admin/stats/top_nav.dart';
import 'package:nam_football/admin/teams/team_home.dart';

class HomeNews extends StatefulWidget {
  const HomeNews({super.key});

  @override
  State<HomeNews> createState() => _HomeNewsState();
}

class _HomeNewsState extends State<HomeNews> {
  // Set the default selected index to 0 (News page)
  int _selectedIndex = 0; // Default to the "News" page (index 0)

  // Define pages for each section
  static final List<Widget> _pages = <Widget>[
    FootballNews(), // News page
    const MatchDatas(), // Matches (Fixtures) page
    const StatsPage(), // Statistics page
    const TeamHome(), // Teams page
  ];
  
  // Handle bottom navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget? _buildFloatingActionButton() {
  switch (_selectedIndex) {
    case 0: // News page
      return FloatingActionButton(
        onPressed: () {
          Get.to(() => ArticleForm());
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add News',
      );
    case 1: // Matches (Fixtures) page
      return FloatingActionButton(
        onPressed: () {
          Get.to(() => const Fixtures());
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Fixture',
      );
    case 3: // Teams page
      return FloatingActionButton(
        onPressed: () {
          print("Floating action button on Teams page pressed");
          // Add functionality for adding a team here
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Team',
      );
    default:
      return null; // No floating button for the Stats page (index 2) or any other unhandled cases
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nam Football",
          style: TextStyle(
            color: Colors.white, // Change heading text color to white
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue, // Set AppBar background color to blue
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages, // Display corresponding page based on index
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space evenly
          children: [
            buildBottomNavItem(Icons.article, "NEWS", 0), // News
            buildBottomNavItem(Icons.emoji_events, "MATCHES", 1), // Matches
            buildBottomNavItem(Icons.bar_chart, "STATS", 2), // Stats
            buildBottomNavItem(Icons.group, "TEAMS", 3), // Teams
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget buildBottomNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        _onItemTapped(index); // Update selected index when an item is tapped
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.blue : Colors.black,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
