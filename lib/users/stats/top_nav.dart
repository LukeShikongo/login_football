import 'package:flutter/material.dart';
import 'package:nam_football/admin/stats/logstandtable.dart';
import 'package:nam_football/admin/stats/top_scorer.dart';
import 'package:nam_football/users/stats/logstandtable.dart'; // Top Scorer page

class StatsPageUsr extends StatelessWidget {
  const StatsPageUsr({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removes the back arrow
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight), // Sets height of the TabBar
            child: Container(
              color: const Color(0xFFcacbcc), // Background color for TabBar
              child: const TabBar(
                indicatorColor: Colors.blue, // Indicator color for selected tab
                labelColor: Colors.blue, // Text color for selected tab
                unselectedLabelColor: Colors.black, // Text color for unselected tab
                tabs: [
                  Tab(text: 'Logstand'), // Tab for Logstand
                  Tab(text: 'Top Scorer'), // Tab for Top Scorer
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            LogstandTableUsr(), // Widget to show Logstand table
            TopScorerPage(), // Widget for the Top Scorer page
          ],
        ),
      ),
    );
  }
}
