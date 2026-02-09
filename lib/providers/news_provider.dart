import 'package:flutter/material.dart';
import '../services/news_service.dart';

class NewsProvider with ChangeNotifier {
  final NewsService _newsService = NewsService();
  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  NewsProvider() {
    fetchNews();
  }

  Future<void> fetchNews() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _articles = await _newsService.fetchRandomFeed();
    } catch (e) {
      _error = 'Failed to fetch news. Please check your internet connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
