import 'dart:convert';
import 'package:http/http.dart' as http;
import 'article_model.dart';

class ApiService {
  static const String _urlBase =
      'https://newsapi.org/v2/top-headlines'
      '?country=us&category=business&apiKey=274f0afbe19748deb8c399fcd2c656f6';

  Future<List<Article>> fetchArticles() async {
    final response = await http.get(Uri.parse(_urlBase));

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat artikel');
    }

    final data = jsonDecode(response.body);

    return (data['articles'] as List)
        .map((json) => Article.fromJson(json))
        .toList();
  }
}