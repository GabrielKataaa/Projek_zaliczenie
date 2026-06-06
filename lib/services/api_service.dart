import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookApiService {
  static const String baseUrl = "https://gutendex.com";

  static Future<List<Book>> fetchBooks({int page = 1, String search = ""}) async {
    String url = "$baseUrl/books?page=$page";
    if (search.isNotEmpty) {
      url += "&search=${Uri.encodeComponent(search)}";
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data["results"] ?? [];
      return results
          .map((json) => Book.fromApi(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("Błąd pobierania danych (HTTP ${response.statusCode})");
    }
  }
}
