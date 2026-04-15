import 'package:flutter_test/flutter_test.dart';
import 'package:news_app/models/article.dart';

void main() {
  group('Article Model', () {
    test('fromJson creates Article correctly', () {
      final json = {
        'title': 'Test Article',
        'description': 'Test description',
        'url': 'https://example.com',
        'urlToImage': 'https://example.com/image.jpg',
        'source': {'name': 'Test Source'},
        'publishedAt': '2026-04-15T12:00:00Z',
        'author': 'Test Author',
        'content': 'Test content',
      };

      final article = Article.fromJson(json);

      expect(article.title, 'Test Article');
      expect(article.description, 'Test description');
      expect(article.url, 'https://example.com');
      expect(article.sourceName, 'Test Source');
      expect(article.author, 'Test Author');
    });

    test('toJson serializes Article correctly', () {
      final article = Article(
        title: 'Test',
        sourceName: 'Source',
        publishedAt: '2026-04-15T12:00:00Z',
      );

      final json = article.toJson();

      expect(json['title'], 'Test');
      expect(json['source']['name'], 'Source');
      expect(json['publishedAt'], '2026-04-15T12:00:00Z');
    });

    test('formattedDate returns correct format', () {
      final article = Article(publishedAt: '2026-04-15T12:00:00Z');
      expect(article.formattedDate, '15 Apr 2026');
    });

    test('formattedDate returns empty for null', () {
      final article = Article();
      expect(article.formattedDate, '');
    });
  });
}
