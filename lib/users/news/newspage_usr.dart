import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nam_football/admin/news/fullartic.dart';
import 'package:nam_football/admin/news/newspage.dart';
import 'package:nam_football/services/database.dart'; 



class FootballNewsUsr extends StatefulWidget {
  @override
  _FootballNewsUsrState createState() => _FootballNewsUsrState();
}

class _FootballNewsUsrState extends State<FootballNewsUsr> {
  List<NewsItem> newsArticles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    setState(() {
      isLoading = true;
    });
    try {
      newsArticles = await DatabaseMethods().fetchArticles();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch articles: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: RefreshIndicator(
        onRefresh: fetchArticles, // Refresh feature
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : newsArticles.isEmpty
                ? Center(
                    child: Text(
                      'No articles available.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: newsArticles.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullArticlePage(
                                newsItem: newsArticles[index] as NewsItem, // Typecast to the expected type
                              ),
                            ),
                          );

                        },
                        child: NewsCard(newsItem: newsArticles[index]),
                      );
                    },
                  ),
      ),  
    );
  }
}

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newsItem.title,
                  maxLines: 2, // Limit title lines to prevent overflow
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    newsItem.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
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
