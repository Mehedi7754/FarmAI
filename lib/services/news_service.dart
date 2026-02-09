import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class NewsArticle {
  final String title;
  final String link;
  final String source;
  final String pubDate;
  final String description;

  NewsArticle({
    required this.title,
    required this.link,
    required this.source,
    required this.pubDate,
    required this.description,
  });
}

class NewsService {
  final List<String> _rssUrls = [
    'https://news.google.com/rss/search?q=%E0%A6%97%E0%A6%AC%E0%A6%BE%E0%A6%A6%E0%A6%BF%E0%A6%AA%E0%A6%B6%E0%A7%81%20%E0%A6%AC%E0%A6%BE%E0%A6%82%E0%A6%B2%E0%A6%AE%E0%A6%A6%E0%A7%87%E0%A6%B6%20when%3A7d&hl=bn&gl=BD&ceid=BD:bn',
    'https://news.google.com/rss/search?q=%E0%A6%97%E0%A6%AC%E0%A6%BE%E0%A6%A6%E0%A6%BF%E0%A6%AA%E0%A6%B6%E0%A7%81%E0%A6%B0%20%E0%A6%B0%E0%A7%8B%E0%A6%97%20OR%20%E0%A6%97%E0%A6%B0%E0%A7%81%E0%A6%B0%20%E0%A6%B0%E0%A7%8B%E0%A6%97%20when%3A30d&hl=bn&gl=BD&ceid=BD:bn',
    'https://news.google.com/rss/search?q=%E0%A6%95%E0%A7%83%E0%A6%B7%E0%A6%BF%20%E0%A6%AC%E0%A6%BE%E0%A6%82%E0%A6%B2%E0%A6%BE%E0%A6%A6%E0%A7%87%E0%A6%B6&hl=bn&gl=BD&ceid=BD:bn'
  ];

  Future<List<NewsArticle>> fetchRandomFeed() async {
    try {
      final random = Random();
      final url = _rssUrls[random.nextInt(_rssUrls.length)];
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        return items.map((node) {
          String description = '';
          try {
            description = node.findElements('description').first.innerText;
            // Clean up HTML tags if any (often RSS descriptions contain HTML snippets)
            description = description.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), '').trim();
          } catch (_) {}

          return NewsArticle(
            title: node.findElements('title').first.innerText,
            link: node.findElements('link').first.innerText,
            source: node.findElements('source').first.innerText,
            pubDate: node.findElements('pubDate').first.innerText,
            description: description,
          );
        }).toList();
      } else {
        throw Exception('Failed to load RSS feed');
      }
    } catch (e) {
      print('Error fetching news: $e');
      rethrow;
    }
  }
}
