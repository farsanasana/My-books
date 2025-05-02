import 'package:flutter/material.dart';

class AppConstants {
  // App theme
  static const Color primaryColor = Colors.indigo;
  static const Color accentColor = Colors.amber;
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Colors.red;

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle authorStyle = TextStyle(
    fontSize: 14.0,
    fontStyle: FontStyle.italic,
  );
  
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14.0,
  );

  // Dimensions
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 8.0;
  
  // Screen Names
  static const String bookListScreen = 'Book List';
  static const String bookDetailScreen = 'Book Details';
  static const String favoritesScreen = 'Favorites';
  
  // Messages
  static const String noFavoritesMessage = 'No favorite books yet. Add some from the book list!';
  static const String loadingMessage = 'Loading books...';
  static const String errorLoadingMessage = 'Error loading books. Please try again.';
  static const String addedToFavoritesMessage = 'Added to favorites';
  static const String removedFromFavoritesMessage = 'Removed from favorites';
}