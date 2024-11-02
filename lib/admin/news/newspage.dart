import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nam_football/admin/news/articleform.dart'; // Import the ArticleForm
import 'package:nam_football/admin/news/fullartic.dart';
import 'package:nam_football/services/database.dart'; // Import your DatabaseMethods class

// Model for NewsItem
class NewsItem {
  String title;
  String description;
  String category;
  String imageUrl;
  String? docId; // Optional field for document ID

  NewsItem({
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.docId,
  });
}

// FootballNews page
class FootballNews extends StatefulWidget {
  @override
  _FootballNewsState createState() => _FootballNewsState();
}

class _FootballNewsState extends State<FootballNews> {
  List<NewsItem> newsArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    setState(() {
      isLoading = true; // Set loading state to true before fetching
    });
    try {
      // Use the fetchArticles method from DatabaseMethods
      newsArticles = await DatabaseMethods().fetchArticles();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch articles: $e');
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false after fetching
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsArticles.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // Navigate to FullArticlePage to view the full article
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullArticlePage(
                          newsItem: newsArticles[index],
                        ),
                      ),
                    );
                  },
                  child: NewsCard(newsItem: newsArticles[index]),
                );
              },
            ),
    );
  }
}

// NewsCard widget
class NewsCard extends StatelessWidget {
  final NewsItem newsItem;

  const NewsCard({required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category label
          Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: getCategoryColor(newsItem.category),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              newsItem.category.toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(width: 10),
          // Title and image only
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newsItem.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                // Image thumbnail with fixed size of 100x100
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    newsItem.imageUrl,
                    width: 100,  // Set width to 100
                    height: 100, // Set height to 100
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 100, color: Colors.grey);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to get color based on category
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'football':
        return Colors.green;
      case 'results':
        return Colors.blue;
      case 'transfers':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
