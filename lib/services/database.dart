import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nam_football/admin/news/newspage.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DatabaseMethods() {
    // Enable Firestore offline data persistence
    _firestore.settings = const Settings(persistenceEnabled: true);
  }

  // Add team details
  Future<void> addTeamDetails(Map<String, dynamic> teamInfoMap, String id) async {
    try {
      await _firestore.collection("Team").doc(id).set(teamInfoMap);
    } catch (e) {
      print("Error adding team details: $e");
      throw e; // Re-throwing the error for higher-level handling/logging
    }
  }

  final CollectionReference teamCollection = FirebaseFirestore.instance.collection('Team');
  CollectionReference get matchCollection => _firestore.collection('matches');

  // Reference to the fixtures collection
  CollectionReference get fixtureCollection {
    return _firestore.collection('fixtures'); // Adjust 'fixtures' to match your Firestore collection name.
  }

  // Fetch all team details with pagination support
  Future<List<Map<String, dynamic>>> getAllTeamDetails({DocumentSnapshot? lastDoc, int limit = 10}) async {
    try {
      Query query = teamCollection.limit(limit);
      
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching team details: $e");
      return []; // Return empty list in case of error
    }
  }

  // Fetch all match details with pagination
  Future<List<Map<String, dynamic>>> getAllMatchDetails({DocumentSnapshot? lastDoc, int limit = 10}) async {
    try {
      Query query = _firestore.collection('fixtures').limit(limit);
      
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error fetching match details: $e");
      return []; // Return empty list in case of error
    }
  }

  // Add a new fixture
  Future<void> addFixtures(Map<String, dynamic> fixtureMap, String id) async {
    try {
      await fixtureCollection.doc(id).set(fixtureMap);
    } catch (e) {
      print('Error adding fixture: $e');
      rethrow;
    }
  }

  // Fetch all fixtures with pagination
  Future<List<Map<String, dynamic>>> getAllFixtures({DocumentSnapshot? lastDoc, int limit = 10}) async {
    try {
      Query query = fixtureCollection.limit(limit);
      
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print("Error fetching fixtures: $e");
      return []; // Return empty list in case of error
    }
  }

  // Update a match by its document ID (e.g., for updating scores or goal scorers)
  Future<void> updateMatch(String matchId, Map<String, dynamic> updatedData) async {
    try {
      await fixtureCollection.doc(matchId).update(updatedData);
    } catch (e) {
      print('Error updating match: $e');
      throw e;
    }
  }

  // Delete a match by its document ID
  Future<void> deleteMatch(String matchId) async {
    try {
      await fixtureCollection.doc(matchId).delete();
    } catch (e) {
      print('Error deleting match: $e');
      throw e;
    }
  }

  // Update team stats after a match result
  Future<void> updateTeamStats(
    String teamId,
    bool won,
    bool lost,
    bool drawn,
    int goalsFor,
    int goalsAgainst,
  ) async {
    DocumentReference teamDoc = _firestore.collection('Team').doc(teamId);

    try {
      // Fetch the current team data
      DocumentSnapshot teamSnapshot = await teamDoc.get();
      Map<String, dynamic> teamData = teamSnapshot.data() as Map<String, dynamic>;

      int matchesPlayed = teamData['Match played'] ?? 0;
      int matchesWon = teamData['Match won'] ?? 0;
      int matchesLost = teamData['Match lost'] ?? 0;
      int matchesDrawn = teamData['Match drawn'] ?? 0;
      int points = teamData['Points'] ?? 0;
      int goalDifference = teamData['Goal difference'] ?? 0;

      // Update matches played
      matchesPlayed += 1;

      if (won) {
        matchesWon += 1;
        points += 3;
      } else if (lost) {
        matchesLost += 1;
      } else if (drawn) {
        matchesDrawn += 1;
        points += 1;
      }

      // Update goal difference
      goalDifference += (goalsFor - goalsAgainst);

      // Save the updated team data
      await teamDoc.update({
        'Match played': matchesPlayed,
        'Match won': matchesWon,
        'Match lost': matchesLost,
        'Match drawn': matchesDrawn,
        'Points': points,
        'Goal difference': goalDifference,
      });

      print("Updated Team Stats for $teamId: Matches Played: $matchesPlayed, Points: $points, Goal Difference: $goalDifference");
    } catch (e) {
      print('Error updating team stats: $e');
      throw e;
    }
  }

  // Add match result after a match is completed
  Future<void> updateMatchResult(
    String matchId,
    int homeScore,
    int awayScore,
    List<String> homeScorers,
    List<String> awayScorers,
  ) async {
    try {
      // Directly updating Firestore with the new match result data
      await fixtureCollection.doc(matchId).update({
        'homeScore': homeScore,
        'awayScore': awayScore,
        'goalScorers': {
          'home': homeScorers,
          'away': awayScorers,
        },
        'isCompleted': true, // Flag to mark the match as completed
      });

      print("Match result updated successfully!");
    } catch (e) {
      print('Error updating match result: $e');
      throw e;
    }
  }

  // Reference to the logstand collection
  CollectionReference get logstandCollection {
    return _firestore.collection('logstand'); // Adjust 'logstand' to match your Firestore collection name.
  }

  // Batch update team stats for performance improvement
  Future<void> batchUpdateTeamStats(String homeTeamId, String awayTeamId, Map<String, dynamic> homeTeamStats, Map<String, dynamic> awayTeamStats) async {
    WriteBatch batch = _firestore.batch();

    DocumentReference homeTeamDoc = _firestore.collection('Team').doc(homeTeamId);
    DocumentReference awayTeamDoc = _firestore.collection('Team').doc(awayTeamId);

    batch.update(homeTeamDoc, homeTeamStats);
    batch.update(awayTeamDoc, awayTeamStats);

    try {
      await batch.commit();
      print('Batch update successful');
    } catch (e) {
      print('Error performing batch update: $e');
      throw e;
    }
  }

  // Save or update an article
  Future<void> saveArticle(NewsItem article, String? docId) async {
    try {
      if (docId == null || docId.isEmpty) {
        // Add a new article
        await _firestore.collection('articles').add({
          'title': article.title,
          'description': article.description,
          'category': article.category,
          'imageUrl': article.imageUrl,
          'createdAt': FieldValue.serverTimestamp(), // Optional: Add created timestamp
        });
      } else {
        // Update existing article
        await _firestore.collection('articles').doc(docId).update({
          'title': article.title,
          'description': article.description,
          'category': article.category,
          'imageUrl': article.imageUrl,
        });
      }
    } catch (e) {
      print("Error saving article: $e");
      throw e; // Rethrow the error to handle it in the UI
    }
  }

  // Fetch articles from the articles collection
  Future<List<NewsItem>> fetchArticles() async {
    List<NewsItem> articlesList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('articles').get();
      for (var doc in querySnapshot.docs) {
        articlesList.add(NewsItem(
          title: doc['title'],
          description: doc['description'],
          category: doc['category'],
          imageUrl: doc['imageUrl'],
          docId: doc.id, // Capture document ID for future updates
        ));
      }
    } catch (e) {
      print("Error fetching articles: $e");
      throw e; // Rethrow the error to handle it in the UI
    }
    return articlesList;
  }

  // Players Information

  // Reference to the "Team squad" collection
  CollectionReference get teamSquadCollection {
    return _firestore.collection('Team squad'); // New collection for players
  }

  // Add a player to the "Team squad"
  Future<void> addPlayer(Map<String, dynamic> playerInfoMap, String id) async {
    try {
      await teamSquadCollection.doc(id).set(playerInfoMap);
    } catch (e) {
      print("Error adding player: $e");
      throw e; // Re-throwing for higher-level handling
    }
  }

  // Fetch all players from the "Team squad" collection with pagination
  Future<List<Map<String, dynamic>>> getAllPlayers({DocumentSnapshot? lastDoc, int limit = 10}) async {
    try {
      Query query = teamSquadCollection.limit(limit);
      
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching players: $e");
      return []; // Return empty list in case of error
    }
  }


  // Initialize or update the match score to 0-0 when the match starts
  Future<void> updateMatchScore(String matchId, int homeScore, int awayScore) async {
    try {
      await fixtureCollection.doc(matchId).update({
        'homeScore': homeScore,
        'awayScore': awayScore,
      });
      print("Match score updated to $homeScore - $awayScore for match ID: $matchId");
    } catch (e) {
      print("Error updating match score: $e");
      throw e;
    }
  }
}
