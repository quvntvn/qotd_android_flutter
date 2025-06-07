import 'dart:convert';
import 'package:http/http.dart' as http;

const _base = 'https://qotd-api-ne8l.onrender.com/api';

class Quote {
  final int id;
  final String citation;
  final String auteur;
  final String? dateCreation;
  Quote.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        citation = j['citation'],
        auteur = j['auteur'],
        dateCreation = j['date_creation'];
}

class QuoteService {
  static Future<Quote> daily() async => _fetch('/daily_quote');
  static Future<Quote> random() async => _fetch('/random_quote');

  static Future<Quote> _fetch(String path) async {
    final res = await http.get(Uri.parse('$_base$path'));
    if (res.statusCode != 200) throw Exception('API error');
    return Quote.fromJson(jsonDecode(res.body));
  }
}
