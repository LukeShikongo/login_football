import 'package:flutter/material.dart';
import 'package:nam_football/admin/news/newspage.dart';
import 'package:nam_football/services/database.dart';

class ArticleForm extends StatefulWidget {
  final NewsItem? newsItem; // Optional parameter for editing an article
  final String? docId;      // Document ID in case of editing

  ArticleForm({this.newsItem, this.docId});

  @override
  _ArticleFormState createState() => _ArticleFormState();
}

class _ArticleFormState extends State<ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  
  bool _isSaving = false; // To track saving state
  String? _errorMessage;  // To display error messages
  String? _selectedCategory; // To store selected category

  // List of categories for the dropdown
  final List<String> _categories = ['Football', 'Results', 'Transfers'];

  @override
  void initState() {
    super.initState();
    if (widget.newsItem != null) {
      _titleController.text = widget.newsItem!.title;
      _descriptionController.text = widget.newsItem!.description;
      _selectedCategory = widget.newsItem!.category; // Load existing category
      _imageUrlController.text = widget.newsItem!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Save or update the article
  Future<void> _saveArticle() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
        _errorMessage = null; // Clear error message
      });

      NewsItem newArticle = NewsItem(
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory!, // Use the selected category
        imageUrl: _imageUrlController.text,
        docId: widget.docId, // Pass the docId for updates
      );

      try {
        await DatabaseMethods().saveArticle(newArticle, widget.docId);
        Navigator.pop(context); // Close the form after saving
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to save article. Please try again.';
        });
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.newsItem == null ? 'Add New Article' : 'Edit Article'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null) 
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                maxLines: 3,
              ),
              SizedBox(height: 10),
              // Dropdown for selecting category
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Category'),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {}); // To update the preview
                },
              ),
              SizedBox(height: 10),
              if (_imageUrlController.text.isNotEmpty)
                Image.network(
                  _imageUrlController.text,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => Text('Invalid Image URL'),
                ),
              SizedBox(height: 20),
              _isSaving 
                ? Center(child: CircularProgressIndicator()) 
                : ElevatedButton(
                    onPressed: _saveArticle,
                    child: Text(widget.newsItem == null ? 'Add Article' : 'Update Article'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
