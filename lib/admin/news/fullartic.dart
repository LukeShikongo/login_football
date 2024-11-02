import 'package:flutter/material.dart';
import 'package:nam_football/admin/news/newspage.dart';


// FullArticlePage widget
class FullArticlePage extends StatelessWidget {
  final NewsItem newsItem;

  const FullArticlePage({required this.newsItem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(newsItem.title),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display article category
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
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: 10),
            // Article image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                newsItem.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.broken_image, size: 200, color: Colors.grey);
                },
              ),
            ),
            SizedBox(height: 20),
            // Article title
            Text(
              newsItem.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Article description
            Text(
              newsItem.description,
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function for category color
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
