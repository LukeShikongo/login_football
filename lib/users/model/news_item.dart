class NewsItem {
  String title;
  String description;
  String category;
  String imageUrl;
  String? docId;

  NewsItem({
    required this.title,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.docId,
  });
}
