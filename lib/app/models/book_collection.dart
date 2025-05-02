import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:my_books/app/models/books.dart';
import 'package:my_books/app/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BookCollection with ChangeNotifier {
  List<Book> _books = [];
  List<Book> _favorites = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;
  final int _booksPerPage = 10;

  // Getters
  List<Book> get books => _books;
  List<Book> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;

  // Constructor that initializes by loading favorites from SharedPreferences
  BookCollection() {
    _loadFavorites();
  }

  // Fetch books from API
  Future<void> fetchBooks() async {
    if (_isLoading || !_hasMorePages) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newBooks = await ApiService.fetchBooks(_currentPage, _booksPerPage);
      
      if (newBooks.isEmpty) {
        _hasMorePages = false;
      } else {
        // Update favorites status for new books
        for (var book in newBooks) {
          book.isFavorite = _favorites.any((fav) => fav.key == book.key);
        }
        
        _books.addAll(newBooks);
        _currentPage++;
      }
    } catch (e) {
      _error = 'Failed to load books: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh and fetch books from the beginning
  Future<void> refreshBooks() async {
    _books = [];
    _currentPage = 1;
    _hasMorePages = true;
    await fetchBooks();
  }

  // Toggle favorite status
  void toggleFavorite(Book book) {
    book.isFavorite = !book.isFavorite;
    
    if (book.isFavorite) {
      _favorites.add(book);
    } else {
      _favorites.removeWhere((fav) => fav.key == book.key);
    }
    
    _saveFavorites();
    notifyListeners();
  }

  // Remove a book from favorites
  void removeFromFavorites(Book book) {
    book.isFavorite = false;
    _favorites.removeWhere((fav) => fav.key == book.key);
    
    // Also update the book in the main list if it exists there
    final bookIndex = _books.indexWhere((b) => b.key == book.key);
    if (bookIndex >= 0) {
      _books[bookIndex].isFavorite = false;
    }
    
    _saveFavorites();
    notifyListeners();
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList('favorites') ?? [];
      
      _favorites = favoritesList.map((bookJson) {
        final Map<String, dynamic> bookMap = json.decode(bookJson);
        final book = Book(
          key: bookMap['key'],
          title: bookMap['title'],
          authors: List<String>.from(bookMap['authors']),
          coverUrl: bookMap['coverUrl'],
          publishYear: bookMap['publishYear'],
          description: bookMap['description'],
          isFavorite: true,
        );
        return book;
      }).toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: ${e.toString()}');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = _favorites.map((book) => json.encode(book.toJson())).toList();
      await prefs.setStringList('favorites', favoritesList);
    } catch (e) {
      debugPrint('Error saving favorites: ${e.toString()}');
    }
  }
}