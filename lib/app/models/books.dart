class Book {
  final String key;
  final String title;
  final List<String> authors;
  final String? coverUrl;
  final String? publishYear;
  final String? description;
  bool isFavorite;

  Book({
    required this.key,
    required this.title,
    required this.authors,
    this.coverUrl,
    this.publishYear,
    this.description,
    this.isFavorite = false,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    // Extract the book key (for unique identification)
    final String key = json['key'] as String? ?? '';
    
    // Extract the title
    final String title = json['title'] as String? ?? 'Unknown Title';
    
    // Extract authors (could be a complex structure)
    List<String> authors = [];
    if (json['authors'] != null) {
      authors = (json['authors'] as List)
          .map((author) => author['name'] as String? ?? 'Unknown Author')
          .toList();
    }
    
    // Handle cover image URLs
    String? coverUrl;
    if (json['covers'] != null && (json['covers'] as List).isNotEmpty) {
      final coverId = json['covers'][0];
      coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }
    
    // Extract publish year
    String? publishYear;
    if (json['first_publish_year'] != null) {
      publishYear = json['first_publish_year'].toString();
    }
    
    // Extract description
    String? description = json['description']?.toString() ?? 'No description available';
    
    return Book(
      key: key,
      title: title,
      authors: authors.isEmpty ? ['Unknown Author'] : authors,
      coverUrl: coverUrl,
      publishYear: publishYear,
      description: description,
    );
  }

  // Convert to a Map for storage
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'authors': authors,
      'coverUrl': coverUrl,
      'publishYear': publishYear,
      'description': description,
      'isFavorite': isFavorite,
    };
  }
}