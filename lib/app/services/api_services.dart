import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_books/app/models/books.dart';
import 'package:my_books/app/utils/error_handling.dart';


class ApiService {
  static const String baseUrl = 'https://openlibrary.org';
  static const String novelsEndpoint = '/subjects/novel.json';

  // Fetch books with pagination
  static Future<List<Book>> fetchBooks(int page, int limit) async {
    try {
      final offset = (page - 1) * limit;
      final url = Uri.parse('$baseUrl$novelsEndpoint?limit=$limit&offset=$offset');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data.containsKey('works')) {
          final List<dynamic> works = data['works'];
          return works.map((work) => Book.fromJson(work)).toList();
        } else {
          return [];
        }
      } else {
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      throw ErrorHandler.handleException('Failed to fetch books', e);
    }
  }

  // Fetch a single book's detailed information
  static Future<Book?> fetchBookDetails(String key) async {
    try {
      // Remove the initial "/works/" from the key if present
      final bookId = key.startsWith('/works/') ? key.substring(7) : key;
      final url = Uri.parse('$baseUrl/works/$bookId.json');
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return _parseBookDetails(data, key);
      } else {
        throw ErrorHandler.handleHttpError(response);
      }
    } catch (e) {
      throw ErrorHandler.handleException('Failed to fetch book details', e);
    }
  }

  // Helper method to parse detailed book information
  static Book _parseBookDetails(Map<String, dynamic> data, String key) {
    // Extract the title
    final String title = data['title'] as String? ?? 'Unknown Title';
    
    // Extract authors (which may require an additional API call in a real app)
    List<String> authors = [];
    if (data['authors'] != null) {
      authors = (data['authors'] as List)
          .map((author) {
            // In a real app, you might need to extract author name from the author key
            if (author is Map && author.containsKey('author')) {
              return author['author']['name'] as String? ?? 'Unknown Author';
            }
            return 'Unknown Author';
          })
          .toList();
    }
    
    // Handle cover image
    String? coverUrl;
    if (data['covers'] != null && (data['covers'] as List).isNotEmpty) {
      final coverId = data['covers'][0];
      coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
    }
    
    // Extract publish year
    String? publishYear;
    if (data['first_publish_date'] != null) {
      publishYear = data['first_publish_date'].toString();
    }
    
    // Extract description
    String? description;
    if (data['description'] != null) {
      if (data['description'] is Map) {
        description = data['description']['value'] as String? ?? 'No description available';
      } else {
        description = data['description'] as String? ?? 'No description available';
      }
    } else {
      description = 'No description available';
    }
    
    return Book(
      key: key,
      title: title,
      authors: authors.isEmpty ? ['Unknown Author'] : authors,
      coverUrl: coverUrl,
      publishYear: publishYear,
      description: description,
    );
  }
}