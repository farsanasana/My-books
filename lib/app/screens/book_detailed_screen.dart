import 'package:flutter/material.dart';
import 'package:my_books/app/models/books.dart';
import 'package:my_books/app/services/api_services.dart';
import 'package:provider/provider.dart';
import '../models/book_collection.dart';
import '../utils/constants.dart';
import '../widgets/loading_indicator.dart';
class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({
    Key? key,
    required this.book,
  }) : super(key: key);

  @override
  _BookDetailScreenState createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  Book? _detailedBook;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
  }

  Future<void> _fetchBookDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load more detailed information for the book
      final book = await ApiService.fetchBookDetails(widget.book.key);
      
      if (book != null) {
        // Make sure to preserve favorite status
        book.isFavorite = widget.book.isFavorite;
        
        setState(() {
          _detailedBook = book;
          _isLoading = false;
        });
      } else {
        // If we couldn't get detailed info, use the book we already have
        setState(() {
          _detailedBook = widget.book;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Fall back to existing book data if the detailed fetch fails
        _detailedBook = widget.book;
      });
    }
  }

  void _toggleFavorite() {
    // Get the book collection and toggle favorite
    final bookCollection = Provider.of<BookCollection>(context, listen: false);
    
    // Use either the detailed book or the original one
    final book = _detailedBook ?? widget.book;
    bookCollection.toggleFavorite(book);
    
    // Update state to reflect changes
    setState(() {});
    
    // Show feedback to the user
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
    // Use either the detailed book or the original one
    final book = _detailedBook ?? widget.book;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.bookDetailScreen),
        actions: [
          IconButton(
            icon: Icon(
              book.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: book.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading book details...')
          : _error != null && _detailedBook == null
              ? ErrorWithRetry(
                  message: 'Error loading details: $_error',
                  onRetry: _fetchBookDetails,
                )
              : _buildBookDetails(book),
    );
  }

  Widget _buildBookDetails(Book book) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book title and author section
          Center(
            child: Column(
              children: [
                // Book cover
                if (book.coverUrl != null)
                  Container(
                    width: 200,
                    height: 300,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                      child: Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholderCover();
                        },
                      ),
                    ),
                  )
                else
                  _buildPlaceholderCover(),
                
                const SizedBox(height: AppConstants.defaultPadding),
                
                // Title
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: AppConstants.smallPadding),
                
                // Authors
                Text(
                  'by ${book.authors.join(', ')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                if (book.publishYear != null) ...[
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Published: ${book.publishYear}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding * 2),
          
          // Description section
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppConstants.smallPadding),
          
          Text(
            book.description ?? 'No description available.',
            style: const TextStyle(fontSize: 16),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding * 2),
          
          // Favorite button at the bottom
          Center(
            child: ElevatedButton.icon(
              icon: Icon(
                book.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              label: Text(
                book.isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
              ),
              onPressed: _toggleFavorite,
              style: ElevatedButton.styleFrom(
                backgroundColor: book.isFavorite ? Colors.red : AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: AppConstants.smallPadding,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: const Center(
        child: Icon(
          Icons.book,
          size: 80,
          color: Colors.grey,
        ),
      ),
    );
  }
}