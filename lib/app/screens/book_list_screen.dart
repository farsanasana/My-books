import 'package:flutter/material.dart';
import 'package:my_books/app/models/books.dart';
import 'package:my_books/app/screens/book_detailed_screen.dart';
import 'package:my_books/app/screens/favorite_screen.dart';
import 'package:my_books/app/widgets/bookcard_details.dart';
import 'package:provider/provider.dart';
import '../models/book_collection.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({Key? key}) : super(key: key);

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    
    // Load initial books
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookCollection>(context, listen: false).fetchBooks();
    });
    
    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8 &&
        !_isLoadingMore) {
      _loadMoreBooks();
    }
  }

  Future<void> _loadMoreBooks() async {
    setState(() {
      _isLoadingMore = true;
    });
    
    await Provider.of<BookCollection>(context, listen: false).fetchBooks();
    
    setState(() {
      _isLoadingMore = false;
    });
  }

  void _navigateToBookDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailScreen(book: book),
      ),
    );
  }

  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FavoritesScreen(),
      ),
    );
  }

  void _toggleFavorite(Book book) {
    Provider.of<BookCollection>(context, listen: false).toggleFavorite(book);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          book.isFavorite 
              ? AppConstants.addedToFavoritesMessage 
              : AppConstants.removedFromFavoritesMessage,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.bookListScreen),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: _navigateToFavorites,
          ),
        ],
      ),
      body: Consumer<BookCollection>(
        builder: (context, bookCollection, child) {
          if (bookCollection.books.isEmpty && bookCollection.isLoading) {
            return const LoadingIndicator();
          }
          
          if (bookCollection.books.isEmpty && bookCollection.error != null) {
            return ErrorWithRetry(
              message: bookCollection.error ?? AppConstants.errorLoadingMessage,
              onRetry: () => bookCollection.refreshBooks(),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => bookCollection.refreshBooks(),
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: bookCollection.books.length + 
                  (bookCollection.isLoading || bookCollection.hasMorePages ? 1 : 0),
              itemBuilder: (context, index) {
                // If we've reached the end and we're loading more or have more pages
                if (index == bookCollection.books.length) {
                  return bookCollection.isLoading 
                      ? const BottomLoadingIndicator()
                      : const SizedBox.shrink();
                }
                
                final book = bookCollection.books[index];
                return BookCard(
                  book: book,
                  onTap: () => _navigateToBookDetail(book),
                  onFavoriteToggle: () => _toggleFavorite(book),
                );
              },
            ),
          );
        },
      ),
    );
  }
}