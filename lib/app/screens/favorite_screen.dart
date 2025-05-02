import 'package:flutter/material.dart';
import 'package:my_books/app/models/books.dart';
import 'package:my_books/app/screens/book_detailed_screen.dart';
import 'package:my_books/app/widgets/bookcard_details.dart';
import 'package:provider/provider.dart';

import '../models/book_collection.dart';
import '../utils/constants.dart';


class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  void _navigateToBookDetail(BuildContext context, Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(book: book),
      ),
    );
  }

  void _removeFavorite(BuildContext context, Book book) {
    // Get the book collection
    final bookCollection = Provider.of<BookCollection>(context, listen: false);
    
    // Remove from favorites
    bookCollection.removeFromFavorites(book);
    
    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppConstants.removedFromFavoritesMessage),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.favoritesScreen),
      ),
      body: Consumer<BookCollection>(
        builder: (context, bookCollection, child) {
          final favorites = bookCollection.favorites;
          
          if (favorites.isEmpty) {
            return _buildEmptyFavorites(context);
          }
          
          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final book = favorites[index];
              return Dismissible(
                key: Key('favorite_${book.key}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppConstants.defaultPadding),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  _removeFavorite(context, book);
                },
                child: BookCard(
                  book: book,
                  onTap: () => _navigateToBookDetail(context, book),
                  onFavoriteToggle: () => _removeFavorite(context, book),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyFavorites(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          const Text(
            AppConstants.noFavoritesMessage,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton.icon(
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go to Book List'),
            onPressed: () => Navigator.pop(context,true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}