class Article {
  final String? title;
  final String? description;
  final String? content;
  final String? url;
  final String? urlToImage;
  final String? sourceName;
  final String? publishedAt;
  final String? author;

  Article({
    this.title,
    this.description,
    this.content,
    this.url,
    this.urlToImage,
    this.sourceName,
    this.publishedAt,
    this.author,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['title'] as String?,
      description: json['description'] as String?,
      content: json['content'] as String?,
      url: json['url'] as String?,
      urlToImage: json['urlToImage'] as String?,
      sourceName: json['source']?['name'] as String?,
      publishedAt: json['publishedAt'] as String?,
      author: json['author'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'url': url,
      'urlToImage': urlToImage,
      'source': {'name': sourceName},
      'publishedAt': publishedAt,
      'author': author,
    };
  }

  /// Returns a formatted date string, e.g. "15 Apr 2026"
  String get formattedDate {
    if (publishedAt == null) return '';
    try {
      final date = DateTime.parse(publishedAt!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return '';
    }
  }

  /// Returns relative time string like "2 hours ago"
  String get timeAgo {
    if (publishedAt == null) return '';
    try {
      final date = DateTime.parse(publishedAt!);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      if (difference.inDays < 7) return '${difference.inDays}d ago';
      return formattedDate;
    } catch (_) {
      return '';
    }
  }
}
