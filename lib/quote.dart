import 'dart:convert';
import 'package:http/http.dart' as http;

class Quote {
  Quote({required this.text, required this.author});

  final String text;
  final String author;

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['quote'] as String,
      author: json['author'] as String,
    );
  }
}

Future<Quote> fetchQuote() async {
  final url = Uri.parse('https://dummyjson.com/quotes/random');

  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception('The quote server answered ${response.statusCode}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  return Quote.fromJson(data);
}