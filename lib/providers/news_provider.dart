import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<Article> _articles = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;
  String _selectedCategory = 'general';

  // ── Getters ──────────────────────────────────────────────────────────
  List<Article> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  String get selectedCategory => _selectedCategory;
  bool get hasError => _errorMessage != null;
  bool get hasData => _articles.isNotEmpty;

  // ── Categories ───────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> categories = [
    {'key': 'general', 'label': 'General', 'icon': Icons.public},
    {'key': 'technology', 'label': 'Tech', 'icon': Icons.computer},
    {'key': 'sports', 'label': 'Sports', 'icon': Icons.sports_soccer},
    {'key': 'business', 'label': 'Business', 'icon': Icons.business},
    {'key': 'health', 'label': 'Health', 'icon': Icons.health_and_safety},
    {'key': 'entertainment', 'label': 'Fun', 'icon': Icons.movie},
    {'key': 'science', 'label': 'Science', 'icon': Icons.science},
  ];

  // ── Fetch Headlines ──────────────────────────────────────────────────
  Future<void> fetchHeadlines() async {
    _isLoading = true;
    _errorMessage = null;
    _isOffline = false;
    notifyListeners();

    try {
      _articles = await _newsService.fetchTopHeadlines(
        category: _selectedCategory,
      );

      // Detect if we got data from cache (offline mode)
      // dart:io's InternetAddress is not supported on web
      if (!kIsWeb) {
        try {
          final result = await InternetAddress.lookup('google.com');
          _isOffline = result.isEmpty || result[0].rawAddress.isEmpty;
        } on SocketException {
          _isOffline = true;
        }
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = _getUserFriendlyError(e);
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Change Category ──────────────────────────────────────────────────
  Future<void> changeCategory(String category) async {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    await fetchHeadlines();
  }

  // ── Search Articles ──────────────────────────────────────────────────
  Future<List<Article>> searchArticles(String query) async {
    return _newsService.searchArticles(query);
  }

  // ── Retry ────────────────────────────────────────────────────────────
  Future<void> retry() async {
    await fetchHeadlines();
  }

  // ── Error Message Helper ─────────────────────────────────────────────
  String _getUserFriendlyError(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('socket') || message.contains('internet') || message.contains('network')) {
      return 'No internet connection.\nPlease check your network and try again.';
    }
    if (message.contains('timeout')) {
      return 'Connection timed out.\nPlease try again later.';
    }
    if (message.contains('cache') || message.contains('cached')) {
      return 'No data available.\nConnect to the internet to load news.';
    }

    return 'Something went wrong.\nPlease try again.';
  }
}
