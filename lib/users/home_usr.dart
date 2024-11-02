import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:nam_football/admin/home_page.dart';
import 'package:nam_football/admin/matches/matchdata.dart';
import 'package:nam_football/admin/news/newspage.dart';
import 'package:nam_football/admin/stats/top_nav.dart';
import 'package:nam_football/admin/teams/team_home.dart';
import 'package:nam_football/users/authentication/login_screen.dart';
import 'package:nam_football/users/matches/matchdata_usr.dart';

class HomeUsrUsr extends StatefulWidget {
  const HomeUsrUsr({super.key});

  @override
  State<HomeUsrUsr> createState() => _HomeNewsState();
}

class _HomeNewsState extends State<HomeUsrUsr> {
  int _selectedIndex = 0; // Default selected index

  static final List<Widget> _pages = <Widget>[
    FootballNews(), // News page
    const MatchDatasUsr(), // Matches (Fixtures) page
    const StatsPage(), // Statistics page
    const TeamHome(), // Teams page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Function to handle 'Admin' button press
  void _goToAdminPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MatchDatas(), // Example: Navigate to Matches Admin Page
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nam Football",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: () {
              // Get.to(() => const HomeNews());
              Get.to(() => LoginScreen());
            },
            
            child: const Text(
              'Admin',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            buildBottomNavItem(Icons.article, "NEWS", 0),
            buildBottomNavItem(Icons.emoji_events, "MATCHES", 1),
            buildBottomNavItem(Icons.bar_chart, "STATS", 2),
            buildBottomNavItem(Icons.group, "TEAMS", 3),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () {
        _onItemTapped(index);
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
