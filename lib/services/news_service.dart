import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';

class NewsService {
  static const String _baseUrl = 'https://newsapi.org/v2';
  static const Duration _timeout = Duration(seconds: 15);

  // CORS proxy for web development (NewsAPI blocks browser requests)
  static const String _corsProxy = 'https://corsproxy.io/?';

  String get _apiKey => dotenv.env['NEWS_API_KEY'] ?? '';

  /// Build a URI that works on both web (via CORS proxy) and mobile (direct)
  Uri _buildUri(String url) {
    if (kIsWeb) {
      // corsproxy.io expects the raw URL appended after '?'
      return Uri.parse('$_corsProxy$url');
    }
    return Uri.parse(url);
  }

  // ── Fetch Top Headlines ──────────────────────────────────────────────
  Future<List<Article>> fetchTopHeadlines({String category = 'general'}) async {
    final cacheKey = 'headlines_$category';

    try {
      final uri = _buildUri(
        '$_baseUrl/top-headlines?country=us&category=$category&apiKey=$_apiKey',
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];

        final articles = articlesJson
            .map((json) => Article.fromJson(json))
            .where((a) => a.title != null && a.title != '[Removed]')
            .toList();

        // Cache the successful response
        await _cacheResponse(cacheKey, json.encode(articlesJson));

        return articles;
      } else {
        throw HttpException('Failed to load news (${response.statusCode})');
      }
    } on SocketException {
      // No internet — try cache
      return _getFromCache(cacheKey);
    } on TimeoutException {
      // Timeout — try cache
      return _getFromCache(cacheKey);
    } catch (e) {
      if (e is HttpException) rethrow;
      // Any other error — try cache
      return _getFromCache(cacheKey);
    }
  }

  // ── Search Articles ──────────────────────────────────────────────────
  Future<List<Article>> searchArticles(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = _buildUri(
        '$_baseUrl/everything?q=${Uri.encodeComponent(query)}&sortBy=publishedAt&pageSize=20&apiKey=$_apiKey',
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> articlesJson = data['articles'] ?? [];

        return articlesJson
            .map((json) => Article.fromJson(json))
            .where((a) => a.title != null && a.title != '[Removed]')
            .toList();
      } else {
        throw HttpException('Search failed (${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    }
  }

  // ── Cache Helpers ────────────────────────────────────────────────────
  Future<void> _cacheResponse(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
    await prefs.setString('${key}_timestamp', DateTime.now().toIso8601String());
  }

  Future<List<Article>> _getFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(key);

    if (cachedData != null && cachedData.isNotEmpty) {
      final List<dynamic> articlesJson = json.decode(cachedData);
      return articlesJson
          .map((json) => Article.fromJson(json))
          .where((a) => a.title != null && a.title != '[Removed]')
          .toList();
    }

    throw Exception('No cached data available. Please connect to the internet.');
  }

  /// Check if the returned data was from cache (for offline banner)
  Future<bool> hasCachedData(String category) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('headlines_$category');
  }
}
